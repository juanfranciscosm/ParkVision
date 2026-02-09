const express = require("express");
const router = express.Router();
const { all } = require("../db/sqlite");

// ✅ Import robusto (funciona si exportas function, {requireAuth}, o default)
const authMod = require("../middleware/requireAuth");
const requireAuth = authMod.requireAuth || authMod.default || authMod;

// ✅ (opcional) para confirmar en consola
// console.log("typeof requireAuth =", typeof requireAuth);

router.use(requireAuth);

// GET /parkings
router.get("/", async (req, res) => {
  try {
    // Si quieres que ADMIN vea todos y OPERATOR solo el suyo:
    if (req.user?.role !== "ADMIN") {
      const rows = await all(
        `SELECT id, name, address, total_spots FROM parkings WHERE id = ? ORDER BY id`,
        [req.user?.parking_id]
      );
      return res.json(rows);
    }

    // ADMIN: todos
    const rows = await all(
      `SELECT id, name, address, total_spots FROM parkings ORDER BY id`
    );
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;
