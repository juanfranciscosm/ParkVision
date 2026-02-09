const express = require("express");
const router = express.Router();
const { get, all } = require("../db/sqlite");

// ✅ Import robusto (funciona si exportas function, {requireAuth}, o default)
const authMod = require("../middleware/requireAuth");
const requireAuth = authMod.requireAuth || authMod.default || authMod;

// ✅ (opcional) para confirmar en consola
// console.log("typeof requireAuth =", typeof requireAuth);

router.use(requireAuth);


function getParkingId(req) {
  // Si viene query param, úsalo; si no, usa el parking del usuario
  const q = req.query.parking_id;
  const pid = q !== undefined ? Number(q) : Number(req.user?.parking_id);
  if (!Number.isFinite(pid)) return null;
  return pid;
}

// 1) Métricas actuales
router.get("/now", async (req, res) => {
  try {
    const parkingId = getParkingId(req);
    if (parkingId === null) return res.status(400).json({ error: "parking_id inválido" });

    const total = await get(
      `SELECT COUNT(*) AS total
       FROM parking_spots
       WHERE parking_id = ? AND is_active = 1`,
      [parkingId]
    );

    const rows = await all(
      `SELECT pss.status, COUNT(*) AS count
       FROM parking_spot_state pss
       JOIN parking_spots ps ON ps.id = pss.spot_id
       WHERE ps.parking_id = ?
       GROUP BY pss.status`,
      [parkingId]
    );

    const counts = { FREE: 0, RESERVED: 0, OCCUPIED: 0 };
    for (const r of rows) counts[r.status] = r.count;

    const totalSpots = total?.total ?? 0;
    const occupied = counts.OCCUPIED;
    const free = counts.FREE;
    const reserved = counts.RESERVED;

    res.json({
      parking_id: parkingId,
      total_spots: totalSpots,
      free,
      reserved,
      occupied,
      occupancy_rate: totalSpots ? occupied / totalSpots : 0,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// 2) Duración promedio
router.get("/avg-duration", async (req, res) => {
  try {
    const parkingId = getParkingId(req);
    if (parkingId === null) return res.status(400).json({ error: "parking_id inválido" });

    const start = req.query.start || "2025-08-01";
    const end = req.query.end || "2026-02-01"; // exclusivo

    const row = await get(
      `SELECT AVG(os.duration_seconds) AS avg_seconds,
              COUNT(*) AS sessions
       FROM occupancy_sessions os
       JOIN parking_spots ps ON ps.id = os.spot_id
       WHERE ps.parking_id = ?
         AND os.ended_at IS NOT NULL
         AND date(os.started_at) >= date(?)
         AND date(os.started_at) < date(?)`,
      [parkingId, start, end]
    );

    const avgSeconds = row?.avg_seconds ?? 0;

    res.json({
      parking_id: parkingId,
      sessions: row?.sessions ?? 0,
      avg_seconds: avgSeconds,
      avg_minutes: avgSeconds ? avgSeconds / 60 : 0,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// 3) Historial mensual
router.get("/monthly", async (req, res) => {
  try {
    const parkingId = getParkingId(req);
    if (parkingId === null) return res.status(400).json({ error: "parking_id inválido" });

    const start = req.query.start || "2025-08-01";
    const end = req.query.end || "2026-02-01";

    const rows = await all(
      `SELECT strftime('%Y-%m', os.started_at) AS month,
              COUNT(*) AS sessions,
              SUM(os.duration_seconds) AS total_seconds,
              AVG(os.duration_seconds) AS avg_seconds
       FROM occupancy_sessions os
       JOIN parking_spots ps ON ps.id = os.spot_id
       WHERE ps.parking_id = ?
         AND os.ended_at IS NOT NULL
         AND date(os.started_at) >= date(?)
         AND date(os.started_at) < date(?)
       GROUP BY month
       ORDER BY month`,
      [parkingId, start, end]
    );

    res.json(rows.map(r => ({
      month: r.month,
      sessions: r.sessions,
      total_hours: (r.total_seconds || 0) / 3600,
      avg_minutes: (r.avg_seconds || 0) / 60
    })));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// 4) Por hora con filtro día semana
router.get("/hourly", async (req, res) => {
  try {
    const parkingId = getParkingId(req);
    if (parkingId === null) return res.status(400).json({ error: "parking_id inválido" });

    const start = req.query.start || "2025-08-01";
    const end = req.query.end || "2026-02-01";
    const dow = req.query.dow; // "0".."6" o "all"

    const dowFilter = (dow !== undefined && dow !== "all")
      ? `AND strftime('%w', os.started_at) = ?`
      : "";

    const params = (dow !== undefined && dow !== "all")
      ? [parkingId, start, end, String(dow)]
      : [parkingId, start, end];

    const rows = await all(
      `SELECT CAST(strftime('%H', os.started_at) AS INTEGER) AS hour,
              COUNT(*) AS sessions,
              AVG(os.duration_seconds) AS avg_seconds
       FROM occupancy_sessions os
       JOIN parking_spots ps ON ps.id = os.spot_id
       WHERE ps.parking_id = ?
         AND os.ended_at IS NOT NULL
         AND date(os.started_at) >= date(?)
         AND date(os.started_at) < date(?)
         ${dowFilter}
       GROUP BY hour
       ORDER BY hour`,
      params
    );

    const filled = Array.from({ length: 24 }, (_, h) => ({
      hour: h,
      sessions: 0,
      avg_minutes: 0,
    }));

    for (const r of rows) {
      filled[r.hour] = {
        hour: r.hour,
        sessions: r.sessions,
        avg_minutes: (r.avg_seconds || 0) / 60,
      };
    }

    res.json(filled);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// 5) Por día de semana
router.get("/by-dow", async (req, res) => {
  try {
    const parkingId = getParkingId(req);
    if (parkingId === null) return res.status(400).json({ error: "parking_id inválido" });

    const start = req.query.start || "2025-08-01";
    const end = req.query.end || "2026-02-01";

    const rows = await all(
      `SELECT CAST(strftime('%w', os.started_at) AS INTEGER) AS dow,
              COUNT(*) AS sessions,
              AVG(os.duration_seconds) AS avg_seconds
       FROM occupancy_sessions os
       JOIN parking_spots ps ON ps.id = os.spot_id
       WHERE ps.parking_id = ?
         AND os.ended_at IS NOT NULL
         AND date(os.started_at) >= date(?)
         AND date(os.started_at) < date(?)
       GROUP BY dow
       ORDER BY dow`,
      [parkingId, start, end]
    );

    res.json(rows.map(r => ({
      dow: r.dow,
      sessions: r.sessions,
      avg_minutes: (r.avg_seconds || 0) / 60
    })));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;
