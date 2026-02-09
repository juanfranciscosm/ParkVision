const express = require("express");
const router = express.Router();
const jwt = require("jsonwebtoken");
const { get } = require("../db/sqlite");
const { requireAuth } = require("../middleware/requireAuth");

// POST /auth/login
// Body: { username, password }
router.post("/login", async (req, res) => {
  try {
    const username = String(req.body?.username || "").trim();
    const password = String(req.body?.password || "");

    if (!username || !password) {
      return res.status(400).json({ error: "username and password are required" });
    }

    const user = await get(
      `SELECT id, parking_id, username, password_hash, role
       FROM users
       WHERE username = ?`,
      [username]
    );

    if (!user) return res.status(401).json({ error: "Invalid credentials" });

    // DEMO: contraseña == password_hash
    if (password !== user.password_hash) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const secret = process.env.JWT_SECRET;
    if (!secret) return res.status(500).json({ error: "JWT_SECRET is not set in .env" });

    const token = jwt.sign(
      {
        sub: user.id,
        username: user.username,
        role: user.role,           // ADMIN u OPERATOR
        parking_id: user.parking_id
      },
      secret,
      { expiresIn: process.env.JWT_EXPIRES_IN || "8h" }
    );

    return res.json({
      ok: true,
      token,
      user: {
        id: user.id,
        username: user.username,
        role: user.role,
        parking_id: user.parking_id,
      },
    });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// GET /auth/me  (útil para que el frontend confirme sesión)
router.get("/me", requireAuth, async (req, res) => {
  // req.user viene del token
  res.json({ ok: true, user: req.user });
});

module.exports = router;
