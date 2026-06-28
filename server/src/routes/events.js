const express = require('express');
const pool = require('../db');
const { requireAuth } = require('../middleware/auth');
const data = require('../events_data');

const router = express.Router();
router.use(requireAuth);

const PATCHABLE = {
  name: 'name', type: 'type', status: 'status', color: 'color', glyph: 'glyph',
  dateLabel: 'date_label', time: 'time', location: 'location', city: 'city',
  capacity: 'capacity', fee: 'fee', attendees: 'attendees', desc: 'descr',
  organizer: 'organizer', taken: 'taken', joinState: 'join_state',
};

router.get('/events', async (req, res, next) => {
  try { res.json(await data.listEvents('events')); } catch (e) { next(e); }
});

router.get('/browse-events', async (req, res, next) => {
  try { res.json(await data.listEvents('browse')); } catch (e) { next(e); }
});

router.get('/browse-events/:id', async (req, res, next) => {
  try {
    const ev = await data.getEvent(req.params.id, 'browse');
    if (!ev) return res.status(404).json({ error: 'not found' });
    res.json(ev);
  } catch (e) { next(e); }
});

router.post('/events', async (req, res, next) => {
  try {
    if (!req.body.id) return res.status(400).json({ error: 'id required' });
    await data.upsertEvent(req.body, 'events');
    res.json({ ok: true });
  } catch (e) { next(e); }
});

router.put('/events/:id', async (req, res, next) => {
  try {
    await data.upsertEvent({ ...req.body, id: req.params.id }, 'events');
    res.json({ ok: true });
  } catch (e) { next(e); }
});

router.patch('/events/:id', async (req, res, next) => {
  try {
    const sets = [];
    const vals = [];
    for (const [k, v] of Object.entries(req.body)) {
      if (PATCHABLE[k]) { sets.push(`${PATCHABLE[k]} = ?`); vals.push(v); }
    }
    if (sets.length === 0) return res.json({ ok: true });
    vals.push(req.params.id);
    await pool.query(`UPDATE events SET ${sets.join(', ')} WHERE id = ?`, vals);
    res.json({ ok: true });
  } catch (e) { next(e); }
});

router.delete('/events/:id', async (req, res, next) => {
  try {
    await pool.query(`DELETE FROM events WHERE id = ?`, [req.params.id]);
    res.json({ ok: true });
  } catch (e) { next(e); }
});

router.put('/events/:id/stalls', async (req, res, next) => {
  try {
    await data.replaceStalls(req.params.id, req.body.stalls || []);
    res.json({ ok: true });
  } catch (e) { next(e); }
});

module.exports = router;
