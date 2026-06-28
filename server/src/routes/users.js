const express = require('express');
const pool = require('../db');
const { requireAuth } = require('../middleware/auth');
const S = require('../serializers');

const router = express.Router();
router.use(requireAuth);

router.get('/profile', async (req, res, next) => {
  try {
    const [rows] = await pool.query(`SELECT * FROM profiles WHERE user_id = ?`, [req.uid]);
    res.json(S.profile(rows[0] || null));
  } catch (e) { next(e); }
});

router.put('/profile', async (req, res, next) => {
  try {
    const p = req.body;
    await pool.query(
      `UPDATE profiles SET name=?, owner=?, role=?, role_label=?, cuisine=?,
         bio=?, color=?, glyph=?, email=?, phone=? WHERE user_id=?`,
      [p.name || '', p.owner || '', p.role === 'vendor' ? 'vendor' : 'organizer',
       p.roleLabel ?? null, p.cuisine ?? null, p.bio || '', p.color || 'blue',
       p.glyph || 'store', p.email || '', p.phone || '', req.uid]
    );
    res.json({ ok: true });
  } catch (e) { next(e); }
});

router.get('/settings', async (req, res, next) => {
  try {
    const [rows] = await pool.query(`SELECT * FROM settings WHERE user_id = ?`, [req.uid]);
    res.json(S.settings(rows[0] || null));
  } catch (e) { next(e); }
});

const SETTING_COLS = {
  pushApps: 'push_apps', pushUpdates: 'push_updates',
  email: 'email', visible: 'visible', location: 'location',
};
router.put('/settings/:key', async (req, res, next) => {
  try {
    const col = SETTING_COLS[req.params.key];
    if (!col) return res.status(400).json({ error: 'unknown setting' });
    await pool.query(
      `UPDATE settings SET ${col} = ? WHERE user_id = ?`,
      [req.body.value ? 1 : 0, req.uid]
    );
    res.json({ ok: true });
  } catch (e) { next(e); }
});

router.get('/participation', async (req, res, next) => {
  try {
    const [rows] = await pool.query(`SELECT * FROM participation WHERE user_id = ?`, [req.uid]);
    res.json(rows.map(S.participation));
  } catch (e) { next(e); }
});

router.put('/participation/:eventId', async (req, res, next) => {
  try {
    const { status, spot } = req.body;
    await pool.query(
      `INSERT INTO participation (user_id, event_id, status, spot) VALUES (?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE status = VALUES(status), spot = VALUES(spot)`,
      [req.uid, req.params.eventId, status || 'pending', spot ?? null]
    );
    res.json({ ok: true });
  } catch (e) { next(e); }
});

router.delete('/participation/:eventId', async (req, res, next) => {
  try {
    await pool.query(`DELETE FROM participation WHERE user_id = ? AND event_id = ?`,
      [req.uid, req.params.eventId]);
    res.json({ ok: true });
  } catch (e) { next(e); }
});

router.get('/notifs', async (req, res, next) => {
  try {
    const [rows] = await pool.query(
      `SELECT * FROM notifs WHERE user_id = ? ORDER BY created_at DESC, id DESC`, [req.uid]);
    res.json(rows.map(S.notif));
  } catch (e) { next(e); }
});

router.put('/notifs/read-all', async (req, res, next) => {
  try {
    await pool.query(`UPDATE notifs SET is_read = 1 WHERE user_id = ?`, [req.uid]);
    res.json({ ok: true });
  } catch (e) { next(e); }
});

router.put('/notifs/:id/read', async (req, res, next) => {
  try {
    await pool.query(`UPDATE notifs SET is_read = 1 WHERE id = ? AND user_id = ?`,
      [req.params.id, req.uid]);
    res.json({ ok: true });
  } catch (e) { next(e); }
});

router.put('/notifs/:id/resolve', async (req, res, next) => {
  try {
    await pool.query(
      `UPDATE notifs SET is_read = 1, actionable = 0, resolved = ? WHERE id = ? AND user_id = ?`,
      [req.body.result ?? null, req.params.id, req.uid]);
    res.json({ ok: true });
  } catch (e) { next(e); }
});

module.exports = router;
