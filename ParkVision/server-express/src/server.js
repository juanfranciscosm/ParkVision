require("dotenv").config();
const express = require("express");
const cors = require("cors");
const morgan = require("morgan");

const spotsRoutes = require("./routes/spots");
const statsRoutes = require("./routes/stats");
const reservationsRoutes = require("./routes/reservations");
const authRoutes = require("./routes/auth"); 
const parkingsRoutes = require("./routes/parkings");



const { startReservationsExpiryJob } = require("./jobs/reservationsExpiry");
const { requireAuth } = require("./middleware/requireAuth");


const app = express();

// Si quieres ser explícito con headers:
app.use(cors({
  origin: "http://localhost:3000",
  allowedHeaders: ["Content-Type", "Authorization"],
}));
app.use(express.json());
app.use(morgan("dev"));

app.get("/", (req, res) => res.json({ ok: true, service: "ParkVision Express API" }));

app.use("/spots", spotsRoutes);
app.use("/reservations", reservationsRoutes);
app.use("/auth", authRoutes); 

// ✅ Protegemos stats: ambos roles pueden acceder mientras tengan token válido
app.use("/stats", requireAuth, statsRoutes);
app.use("/parkings", parkingsRoutes);

const PORT = process.env.PORT || 8000;
app.listen(PORT, () => {
  console.log(`Express running on http://127.0.0.1:${PORT}`);
  startReservationsExpiryJob();
});
