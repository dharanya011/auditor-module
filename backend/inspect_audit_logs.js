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
    const schemas = ['public', 'public'];
    const tables = ['auditor_audit_logs', 'audit_logs'];

    for(let i=0; i<tables.length; i++) {
      console.log(`\n--- ${schemas[i]}.${tables[i]} ---`);
      const colRes = await pool.query(`SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = $1 AND table_name = $2`, [schemas[i], tables[i]]);
      console.log("Columns:", colRes.rows.map(r => r.column_name).join(', '));
      const dataRes = await pool.query(`SELECT * FROM "${schemas[i]}"."${tables[i]}" LIMIT 1`);
      console.log("Data:", dataRes.rows);
    }
  } catch (err) {
    console.error(err);
  } finally {
    pool.end();
  }
}
run();
