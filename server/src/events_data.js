const pool = require('./db');
const S = require('./serializers');

async function tagsFor(eventIds) {
  if (eventIds.length === 0) return new Map();
  const [rows] = await pool.query(
    `SELECT event_id, tag FROM event_tags WHERE event_id IN (?)`,
    [eventIds]
  );
  const map = new Map();
  for (const r of rows) {
    if (!map.has(r.event_id)) map.set(r.event_id, []);
    map.get(r.event_id).push(r.tag);
  }
  return map;
}

async function stallsFor(eventIds) {
  if (eventIds.length === 0) return new Map();
  const [rows] = await pool.query(
    `SELECT * FROM stalls WHERE event_id IN (?) ORDER BY position ASC`,
    [eventIds]
  );
  const map = new Map();
  for (const r of rows) {
    if (!map.has(r.event_id)) map.set(r.event_id, []);
    map.get(r.event_id).push(S.stall(r));
  }
  return map;
}

async function listEvents(collection) {
  const [rows] = await pool.query(
    `SELECT * FROM events WHERE collection = ? ORDER BY id ASC`,
    [collection]
  );
  const ids = rows.map((r) => r.id);
  const [tags, stalls] = await Promise.all([tagsFor(ids), stallsFor(ids)]);
  return rows.map((r) => S.event(r, tags.get(r.id) || [], stalls.get(r.id) || []));
}

async function getEvent(id, collection) {
  const params = collection ? [id, collection] : [id];
  const where = collection ? 'id = ? AND collection = ?' : 'id = ?';
  const [rows] = await pool.query(`SELECT * FROM events WHERE ${where}`, params);
  if (rows.length === 0) return null;
  const [tags, stalls] = await Promise.all([tagsFor([id]), stallsFor([id])]);
  return S.event(rows[0], tags.get(id) || [], stalls.get(id) || []);
}

async function replaceStalls(eventId, stalls) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    await conn.query(`DELETE FROM stalls WHERE event_id = ?`, [eventId]);
    let pos = 0;
    for (const s of stalls) {
      await conn.query(
        `INSERT INTO stalls (id, event_id, position, name, cuisine, owner, status, spot, fee)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [s.id, eventId, pos++, s.name || '', s.cuisine || '', s.owner || '',
         s.status || 'pending', s.spot || '-', s.fee || 0]
      );
    }
    await conn.commit();
  } catch (e) {
    await conn.rollback();
    throw e;
  } finally {
    conn.release();
  }
}

async function upsertEvent(e, collection = 'events') {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    await conn.query(
      `INSERT INTO events
        (id, collection, name, type, status, color, glyph, date_label, time,
         location, city, capacity, fee, attendees, descr, organizer, taken, join_state)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
       ON DUPLICATE KEY UPDATE
         name=VALUES(name), type=VALUES(type), status=VALUES(status),
         color=VALUES(color), glyph=VALUES(glyph), date_label=VALUES(date_label),
         time=VALUES(time), location=VALUES(location), city=VALUES(city),
         capacity=VALUES(capacity), fee=VALUES(fee), attendees=VALUES(attendees),
         descr=VALUES(descr), organizer=VALUES(organizer), taken=VALUES(taken),
         join_state=VALUES(join_state)`,
      [e.id, collection, e.name || '', e.type || '', e.status || 'upcoming',
       e.color || 'blue', e.glyph || 'store', e.dateLabel || '', e.time || '',
       e.location || '', e.city || '', e.capacity || 0, e.fee || 0,
       e.attendees || '', e.desc || '', e.organizer ?? null,
       e.taken ?? null, e.joinState ?? null]
    );

    await conn.query(`DELETE FROM event_tags WHERE event_id = ?`, [e.id]);
    for (const tag of e.tags || []) {
      await conn.query(`INSERT INTO event_tags (event_id, tag) VALUES (?, ?)`, [e.id, tag]);
    }

    await conn.query(`DELETE FROM stalls WHERE event_id = ?`, [e.id]);
    let pos = 0;
    for (const s of e.stalls || []) {
      await conn.query(
        `INSERT INTO stalls (id, event_id, position, name, cuisine, owner, status, spot, fee)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [s.id, e.id, pos++, s.name || '', s.cuisine || '', s.owner || '',
         s.status || 'pending', s.spot || '-', s.fee || 0]
      );
    }
    await conn.commit();
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

module.exports = { listEvents, getEvent, replaceStalls, upsertEvent };
