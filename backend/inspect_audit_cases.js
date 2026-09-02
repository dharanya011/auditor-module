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
    const colRes = await pool.query(`SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'audit_case_items'`);
    console.log("Columns:", colRes.rows);
    const countRes = await pool.query(`SELECT count(*) FROM public.audit_case_items`);
    console.log("Count:", countRes.rows[0].count);
    const dataRes = await pool.query(`SELECT * FROM public.audit_case_items LIMIT 2`);
    console.log("Data:", dataRes.rows);
  } catch (err) {
    console.error(err);
  } finally {
    pool.end();
  }
}
run();
