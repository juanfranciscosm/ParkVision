const { all, run } = require("../db/sqlite");

function startReservationsExpiryJob() {
  const intervalMs = Number(process.env.EXPIRY_JOB_INTERVAL_MS || 1000); // demo: 1s

  setInterval(async () => {
    try {
      const nowExpr = "datetime('now','localtime')";

      // Reservas activas que ya vencieron
      const expired = await all(
        `SELECT id, spot_id
         FROM reservations
         WHERE status='ACTIVE' AND expires_at <= ${nowExpr}`
      );

      if (!expired.length) return;

      for (const r of expired) {
        // marcar EXPIRED
        await run(
          `UPDATE reservations
           SET status='EXPIRED', cancelled_at=${nowExpr}
           WHERE id=? AND status='ACTIVE'`,
          [r.id]
        );

        // liberar spot SOLO si sigue RESERVED
        await run(
          `UPDATE parking_spot_state
           SET status='FREE', updated_at=${nowExpr}
           WHERE spot_id=? AND status='RESERVED'`,
          [r.spot_id]
        );

        // evento
        await run(
          `INSERT INTO events (spot_id, event_type, created_at, metadata)
           VALUES (?, 'RESERVATION_EXPIRED', ${nowExpr}, ?)`,
          [r.spot_id, JSON.stringify({ reservation_id: r.id })]
        );
      }
    } catch (e) {
      console.error("Expiry job error:", e.message);
    }
  }, intervalMs);

  console.log(`Reservation expiry job running every ${intervalMs} ms`);
}

module.exports = { startReservationsExpiryJob };
