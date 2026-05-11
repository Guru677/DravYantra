require('dotenv').config();
const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');
const { pool, initDB } = require('./db');

const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const app = express();
app.use(cors());
app.use(express.json());

// Log all requests
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Initialize DB
initDB();

// Middleware to verify Firebase token
const verifyToken = async (req, res, next) => {
  const token = req.headers.authorization?.split('Bearer ')[1];
  if (!token) return res.status(401).json({ error: 'No token provided' });

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error("Token verification failed:", error);
    res.status(401).json({ error: 'Invalid token' });
  }
};

// Sync User info on login/signup
app.post('/api/users/sync', verifyToken, async (req, res) => {
  const { uid, email } = req.user;
  const { full_name, role = 'fleet_owner' } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO users (uid, email, full_name, role) 
       VALUES ($1, $2, $3, $4) 
       ON CONFLICT (uid) 
       DO UPDATE SET email = EXCLUDED.email, full_name = COALESCE(EXCLUDED.full_name, users.full_name) 
       RETURNING *`,
      [uid, email, full_name, role]
    );
    res.json({ message: 'User synced', user: result.rows[0] });
  } catch (err) {
    console.error('Error syncing user:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Check Onboarding status
app.get('/api/onboarding', verifyToken, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM fleet_onboarding WHERE uid = $1', [req.user.uid]);
    res.json({ completed: result.rows.length > 0, data: result.rows[0] || null });
  } catch (err) {
    console.error('Error checking onboarding:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Save Onboarding data
app.post('/api/onboarding', verifyToken, async (req, res) => {
  const { company_name, gstin, contact_number, city, state } = req.body;
  
  if (!company_name) return res.status(400).json({ error: 'Company name is required' });

  try {
    const result = await pool.query(
      `INSERT INTO fleet_onboarding (uid, company_name, gstin, contact_number, city, state) 
       VALUES ($1, $2, $3, $4, $5, $6) 
       ON CONFLICT (uid) 
       DO UPDATE SET 
         company_name = EXCLUDED.company_name,
         gstin = EXCLUDED.gstin,
         contact_number = EXCLUDED.contact_number,
         city = EXCLUDED.city,
         state = EXCLUDED.state
       RETURNING *`,
      [req.user.uid, company_name, gstin, contact_number, city, state]
    );
    res.json({ message: 'Onboarding completed', data: result.rows[0] });
  } catch (err) {
    console.error('Error saving onboarding data:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
