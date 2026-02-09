const express = require("express");
const router = express.Router();
const { all, get, run } = require("../db/sqlite");

const ALLOWED = new Set(["FREE", "RESERVED", "OCCUPIED"]);

// GET /spots
router.get("/", async (req, res) => {
  try {
    const rows = await all(`
      SELECT 
            ps.id            AS spot_id,
            ps.code          AS code,
            COALESCE(pss.status, 'FREE')     AS status,
            COALESCE(pss.updated_at, datetime('now','localtime')) AS updated_at
      FROM parking_spots ps
      LEFT JOIN parking_spot_state pss ON ps.id = pss.spot_id
      WHERE ps.is_active = 1
      ORDER BY ps.id
    `);
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});


// GET /spots/:spot_id
router.get("/:spot_id", async (req, res) => {
  try {
    const row = await get(
      `
      SELECT 
          status,
          updated_at
      FROM parking_spot_state
      WHERE spot_id = ?
      `,
      [req.params.spot_id]
    );

    if (!row) return res.status(404).json({ error: "Spot not found" });
    res.json(row);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

/**
 * PATCH /spots/:spot_id/state
 * Body JSON:
 *   { "status": "FREE" | "RESERVED" | "OCCUPIED", "source": "MANUAL" | "QR" | "VISION" }
 *
 * Nota:
 * - Actualiza parking_spot_state
 * - Opcional: registra/cierras occupancy_sessions si tu esquema lo soporta
 */
router.patch("/:spot_id/state", async (req, res) => {
  try {
    const spotId = Number(req.params.spot_id);
    const status = String(req.body?.status || "").toUpperCase();
    const source = String(req.body?.source || "MANUAL").toUpperCase(); // opcional

    if (!Number.isFinite(spotId)) {
      return res.status(400).json({ error: "Invalid spot_id" });
    }
    if (!ALLOWED.has(status)) {
      return res.status(400).json({ error: "Invalid status. Use FREE, RESERVED, or OCCUPIED." });
    }

    // Verifica que la plaza exista
    const spot = await get(`SELECT id, code FROM parking_spots WHERE id = ?`, [spotId]);
    if (!spot) return res.status(404).json({ error: "Spot not found" });

    // Lee estado actual
    const current = await get(`SELECT status FROM parking_spot_state WHERE spot_id = ?`, [spotId]);
    const oldStatus = current?.status || null;

    // Upsert estado
    const updatedAtExpr = "datetime('now','localtime')";
    const upd = await run(
      `UPDATE parking_spot_state SET status = ?, updated_at = ${updatedAtExpr} WHERE spot_id = ?`,
      [status, spotId]
    );

    if (upd.changes === 0) {
      await run(
        `INSERT INTO parking_spot_state (spot_id, status, updated_at) VALUES (?, ?, ${updatedAtExpr})`,
        [spotId, status]
      );
    }

    // --- Opcional: manejar sesiones si tienes occupancy_sessions ---
    // Si tu tabla occupancy_sessions existe con (spot_id, started_at, ended_at, duration_seconds, source)
    // y quieres registrar cambios manuales:
    if (oldStatus !== status) {
      if (oldStatus !== "OCCUPIED" && status === "OCCUPIED") {
        await run(
          `INSERT INTO occupancy_sessions (spot_id, started_at, ended_at, duration_seconds, source)
           VALUES (?, ${updatedAtExpr}, NULL, NULL, ?)`,
          [spotId, source]
        );
      }

      if (oldStatus === "OCCUPIED" && status !== "OCCUPIED") {
        // cierra sesión abierta (ended_at IS NULL)
        await run(
          `UPDATE occupancy_sessions
           SET ended_at = ${updatedAtExpr},
               duration_seconds = CAST((julianday(${updatedAtExpr}) - julianday(started_at)) * 86400 AS INTEGER)
           WHERE spot_id = ? AND ended_at IS NULL`,
          [spotId]
        );
      }
    }

    // Respuesta final
    const row = await get(
      `
      SELECT ps.id, ps.code, st.status, st.updated_at
      FROM parking_spots ps
      JOIN parking_spot_state st ON st.spot_id = ps.id
      WHERE ps.id = ?
      `,
      [spotId]
    );

    res.json({
      ok: true,
      previous_status: oldStatus,
      spot: row,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;
