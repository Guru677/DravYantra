const { Pool } = require('pg');

const pool = new Pool({
  user: process.env.PG_USER || 'postgres',
  host: process.env.PG_HOST || 'localhost',
  database: process.env.PG_DATABASE || 'dravyantra',
  password: process.env.PG_PASSWORD || 'postgres',
  port: process.env.PG_PORT || 5432,
});

const initDB = async () => {
  const client = await pool.connect();
  try {
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        uid VARCHAR(128) PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        full_name VARCHAR(255),
        role VARCHAR(50) DEFAULT 'fleet_owner',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS fleet_onboarding (
        id SERIAL PRIMARY KEY,
        uid VARCHAR(128) REFERENCES users(uid) ON DELETE CASCADE,
        company_name VARCHAR(255) NOT NULL,
        gstin VARCHAR(50),
        contact_number VARCHAR(50),
        city VARCHAR(100),
        state VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(uid)
      );
    `);
    console.log("Database initialized successfully");
  } catch (err) {
    console.error("Error initializing database:", err);
  } finally {
    client.release();
  }
};

module.exports = { pool, initDB };
