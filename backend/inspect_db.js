const { Pool } = require('pg');
require('dotenv').config({path: '.env'});
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD
});

async function run() {
  try {
    const res = await pool.query("SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog', 'information_schema') ORDER BY table_schema, table_name;");
    console.log("TABLES:");
    for (let row of res.rows) {
      console.log(`- ${row.table_schema}.${row.table_name}`);
      const colRes = await pool.query(`SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = $1 AND table_name = $2`, [row.table_schema, row.table_name]);
      console.log(`  Columns: ${colRes.rows.map(c => c.column_name).join(', ')}`);
    }
  } catch (err) {
    console.error(err);
  } finally {
    pool.end();
  }
}
run();
