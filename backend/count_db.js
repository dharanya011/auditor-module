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
    for (let row of res.rows) {
      const colRes = await pool.query(`SELECT count(*) FROM "${row.table_schema}"."${row.table_name}"`);
      const count = parseInt(colRes.rows[0].count, 10);
      if (count > 0) {
        console.log(`- ${row.table_schema}.${row.table_name}: ${count} rows`);
      }
    }
  } catch (err) {
    console.error(err);
  } finally {
    pool.end();
  }
}
run();
