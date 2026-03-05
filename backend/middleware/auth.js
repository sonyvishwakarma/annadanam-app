const jwt = require('jsonwebtoken');

const auth = async (req, res, next) => {
  try {
    const authHeader = req.header('Authorization');
    const token = authHeader?.replace('Bearer ', '');

    console.log(`[AUTH] Path: ${req.path} | Token present: ${!!token}`);

    if (!token) {
      console.log('[AUTH] Denied: No token provided');
      return res.status(401).json({ 
        success: false, 
        message: 'No authentication token, access denied' 
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret');
    
    // Check if token version is still valid
    const db = require('../database/db');
    const database = db.getDb();
    const user = await database.get('SELECT tokenVersion FROM users WHERE id = ?', [decoded.id]);
    
    if (!user || (decoded.tokenVersion && user.tokenVersion > decoded.tokenVersion)) {
      return res.status(401).json({ 
        success: false, 
        message: 'Session expired or invalidated. Please login again.' 
      });
    }

    req.user = decoded;
    next();
  } catch (error) {
    console.log(`[AUTH] Denied: ${error.message}`);
    res.status(401).json({ 
      success: false, 
      message: 'Token is invalid or expired',
      error: error.message
    });
  }
};

module.exports = auth;
