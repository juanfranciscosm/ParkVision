const express = require("express");
const router = express.Router();
const crypto = require("crypto");
const { all, get, run } = require("../db/sqlite");

// TTL en segundos: demo = 5, real = 900 (15 min)
const TTL_SECONDS = Number(process.env.RESERVATION_TTL_SECONDS || 5);

function makeQrCode() {
  // QR como string único (no estamos validándolo, solo generándolo)
  // Ej: "PV-6f2a...-1700..."
  const rand = crypto.randomBytes(8).toString("hex");
  return `PV-${rand}-${Date.now()}`;
}

/**
 * POST /reservations
 * Body:
 * {
 *   "spot_id": 3,
 *   "driver": { "cedula": "...", "full_name":"...", "phone":"...", "email":"..." }
 * }
 */
router.post("/", async (req, res) => {
  const spotId = Number(req.body?.spot_id);
  const driver = req.body?.driver || {};
  const cedula = String(driver?.cedula || "").trim();
  const fullName = String(driver?.full_name || "").trim();
  const phone = String(driver?.phone || "").trim();
  const email = String(driver?.email || "").trim();

  if (!Number.isFinite(spotId)) {
    return res.status(400).json({ error: "Invalid spot_id" });
  }
  if (!cedula) {
    return res.status(400).json({ error: "Driver cedula is required" });
  }

  // Usamos localtime como en el resto de tu backend
  const nowExpr = "datetime('now','localtime')";
  const expiresExpr = `datetime('now','localtime','+${TTL_SECONDS} seconds')`;

  try {
    // Bloqueo para evitar doble reserva simultánea
    await run("BEGIN IMMEDIATE TRANSACTION");

    // Verificar spot existe y está activo
    const spot = await get(`SELECT id, code, is_active FROM parking_spots WHERE id = ?`, [spotId]);
    if (!spot || spot.is_active !== 1) {
      await run("ROLLBACK");
      return res.status(404).json({ error: "Spot not found or inactive" });
    }

    // Verificar estado actual: solo se reserva si está FREE
    const current = await get(
      `SELECT status FROM parking_spot_state WHERE spot_id = ?`,
      [spotId]
    );

    const currentStatus = current?.status || "FREE";
    if (currentStatus !== "FREE") {
      await run("ROLLBACK");
      return res.status(409).json({ error: `Spot is not available (status=${currentStatus})` });
    }

    // Upsert Driver por cédula (sin requerir SQLite upsert)
    let driverRow = await get(`SELECT id FROM drivers WHERE cedula = ?`, [cedula]);

    let driverId;
    if (!driverRow) {
      const ins = await run(
        `INSERT INTO drivers (cedula, full_name, phone, email, created_at)
         VALUES (?, ?, ?, ?, ${nowExpr})`,
        [cedula, fullName || null, phone || null, email || null]
      );
      driverId = ins.lastID;
    } else {
      driverId = driverRow.id;
      // Actualiza datos si vinieron (opcional)
      await run(
        `UPDATE drivers
         SET full_name = COALESCE(NULLIF(?,''), full_name),
             phone     = COALESCE(NULLIF(?,''), phone),
             email     = COALESCE(NULLIF(?,''), email)
         WHERE id = ?`,
        [fullName, phone, email, driverId]
      );
    }

    // Crear reservation
    const qrCode = makeQrCode();
    const insRes = await run(
      `INSERT INTO reservations (spot_id, driver_id, qr_code, reserved_at, expires_at, status)
       VALUES (?, ?, ?, ${nowExpr}, ${expiresExpr}, 'ACTIVE')`,
      [spotId, driverId, qrCode]
    );

    // Poner spot a RESERVED
    const upd = await run(
      `UPDATE parking_spot_state
       SET status='RESERVED', updated_at=${nowExpr}
       WHERE spot_id=?`,
      [spotId]
    );
    if (upd.changes === 0) {
      await run(
        `INSERT INTO parking_spot_state (spot_id, status, updated_at)
         VALUES (?, 'RESERVED', ${nowExpr})`,
        [spotId]
      );
    }

    // Evento
    await run(
      `INSERT INTO events (spot_id, event_type, created_at, metadata)
       VALUES (?, 'RESERVATION_CREATED', ${nowExpr}, ?)`,
      [spotId, JSON.stringify({ reservation_id: insRes.lastID, driver_cedula: cedula })]
    );

    await run("COMMIT");

    // Respuesta con info para frontend
    const reservation = await get(
      `SELECT id, spot_id, driver_id, qr_code, reserved_at, expires_at, status
       FROM reservations WHERE id = ?`,
      [insRes.lastID]
    );

    res.json({ ok: true, reservation });
  } catch (e) {
    try { await run("ROLLBACK"); } catch {}
    res.status(500).json({ error: e.message });
  }
});

// GET /reservations  
router.get("/", async (req, res) => {
  res.json({ ok: true, hint: "Use POST /reservations to create. Use GET /reservations/:id to read." });
});


/**
 * GET /reservations/:id
 * Útil para que el frontend consulte si expiró/canceló.
 */
router.get("/:id", async (req, res) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isFinite(id)) return res.status(400).json({ error: "Invalid id" });

    const row = await get(
      `SELECT id, spot_id, driver_id, qr_code, reserved_at, expires_at, status, cancelled_at
       FROM reservations WHERE id = ?`,
      [id]
    );
    if (!row) return res.status(404).json({ error: "Reservation not found" });

    res.json(row);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

/**
 * POST /reservations/:id/cancel
 * Cancela manualmente (o lo llama el frontend al terminar el contador demo).
 */
router.post("/:id/cancel", async (req, res) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isFinite(id)) return res.status(400).json({ error: "Invalid id" });

    const nowExpr = "datetime('now','localtime')";

    await run("BEGIN IMMEDIATE TRANSACTION");

    const r = await get(
      `SELECT id, spot_id, status FROM reservations WHERE id = ?`,
      [id]
    );
    if (!r) {
      await run("ROLLBACK");
      return res.status(404).json({ error: "Reservation not found" });
    }

    // Solo cancelamos si está ACTIVE (si ya expiró, no hacemos nada)
    if (r.status !== "ACTIVE") {
      await run("ROLLBACK");
      return res.json({ ok: true, message: `No action (status=${r.status})` });
    }

    await run(
      `UPDATE reservations
       SET status='CANCELLED', cancelled_at=${nowExpr}
       WHERE id=?`,
      [id]
    );

    // Liberar spot SOLO si sigue RESERVED
    await run(
      `UPDATE parking_spot_state
       SET status='FREE', updated_at=${nowExpr}
       WHERE spot_id=? AND status='RESERVED'`,
      [r.spot_id]
    );

    await run(
      `INSERT INTO events (spot_id, event_type, created_at, metadata)
       VALUES (?, 'RESERVATION_CANCELLED', ${nowExpr}, ?)`,
      [r.spot_id, JSON.stringify({ reservation_id: id })]
    );

    await run("COMMIT");
    res.json({ ok: true });
  } catch (e) {
    try { await run("ROLLBACK"); } catch {}
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;
