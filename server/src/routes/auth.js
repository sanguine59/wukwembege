const express = require('express');
const bcrypt = require('bcryptjs');
const pool = require('../db');
const { sign, requireAuth } = require('../middleware/auth');

const router = express.Router();

function newId(prefix) {
  return `${prefix}${Date.now()}${Math.floor(Math.random() * 1000)}`;
}

async function ensureProfile(uid, role, { email, name, biz } = {}) {
  const [rows] = await pool.query(`SELECT user_id FROM profiles WHERE user_id = ?`, [uid]);
  if (rows.length > 0) return;
  await pool.query(
    `INSERT INTO profiles (user_id, name, owner, role, role_label, bio, color, glyph, email, phone)
     VALUES (?, ?, ?, ?, ?, '', ?, ?, ?, '')`,
    [uid, biz || '', name || '', role,
     role === 'organizer' ? 'Event organizer' : 'Food vendor',
     role === 'organizer' ? 'blue' : 'indigo',
     role === 'organizer' ? 'calendar' : 'store',
     email || '']
  );
  await pool.query(
    `INSERT INTO settings (user_id, push_apps, push_updates, email, visible, location)
     VALUES (?, 1, 1, 0, 1, 1)`,
    [uid]
  );
}

router.post('/register', async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ error: 'email and password required' });
    const [existing] = await pool.query(`SELECT id FROM users WHERE email = ?`, [email]);
    if (existing.length > 0) return res.status(409).json({ error: 'email already in use' });
    const uid = newId('u');
    const hash = await bcrypt.hash(password, 10);
    await pool.query(`INSERT INTO users (id, email, password_hash) VALUES (?, ?, ?)`, [uid, email, hash]);
    res.json({ token: sign(uid), uid });
  } catch (e) { next(e); }
});

router.post('/login', async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ error: 'email and password required' });
    const [rows] = await pool.query(`SELECT id, password_hash FROM users WHERE email = ?`, [email]);
    if (rows.length === 0) return res.status(401).json({ error: 'invalid credentials' });
    const ok = await bcrypt.compare(password, rows[0].password_hash);
    if (!ok) return res.status(401).json({ error: 'invalid credentials' });
    res.json({ token: sign(rows[0].id), uid: rows[0].id });
  } catch (e) { next(e); }
});

router.post('/ensure', requireAuth, async (req, res, next) => {
  try {
    const { role, email, name, biz } = req.body;
    await ensureProfile(req.uid, role === 'vendor' ? 'vendor' : 'organizer', { email, name, biz });
    res.json({ ok: true });
  } catch (e) { next(e); }
});

router.post('/password-reset', (req, res) => {
  res.status(501).json({
    deprecated: true,
    error: 'Password reset is deprecated in the Node.js + Express version because there is no mail server. It is only available in the Firebase version.',
  });
});

module.exports = { router, newId };
