require("dotenv").config();
const { all, get } = require("./src/db/sqlite");

(async () => {
  try {
    const tables = await all("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name");
    console.log("TABLES:", tables);

    const count = await get("SELECT COUNT(*) as n FROM parking_spots");
    console.log("parking_spots count:", count);
  } catch (e) {
    console.error("ERROR:", e.message);
  }
})();
