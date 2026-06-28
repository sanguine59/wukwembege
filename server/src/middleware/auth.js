const jwt = require('jsonwebtoken');

const SECRET = process.env.JWT_SECRET || 'shane';

function sign(uid) {
  return jwt.sign({ uid }, SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '30d',
  });
}

function requireAuth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'missing token' });
  try {
    const payload = jwt.verify(token, SECRET);
    req.uid = payload.uid;
    next();
  } catch (_) {
    return res.status(401).json({ error: 'invalid token' });
  }
}

module.exports = { sign, requireAuth };
