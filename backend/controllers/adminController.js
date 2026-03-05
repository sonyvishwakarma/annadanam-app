const db = require('../database/db');
const asyncHandler = require('express-async-handler');

class AdminController {
  getGlobalStats = asyncHandler(async (req, res) => {
    const database = db.getDb();
    
    const stats = await database.get(`
      SELECT 
        (SELECT COUNT(*) FROM users WHERE role = 'donor') as totalDonors,
        (SELECT COUNT(*) FROM users WHERE role = 'volunteer') as totalVolunteers,
        (SELECT COUNT(*) FROM users WHERE role = 'recipient') as totalRecipients,
        (SELECT COUNT(*) FROM food_requests WHERE status = 'pending') as pendingRequests,
        (SELECT COUNT(*) FROM donations WHERE DATE(createdAt) = DATE('now')) as todayDonations,
        (SELECT COUNT(*) FROM delivery_tasks WHERE DATE(assignedAt) = DATE('now')) as todayDeliveries,
        (SELECT COUNT(*) FROM food_requests WHERE DATE(createdAt) = DATE('now')) as todayRequests
    `);

    res.status(200).json({
      success: true,
      stats: {
        totalDonors: stats.totalDonors,
        totalVolunteers: stats.totalVolunteers,
        totalRecipients: stats.totalRecipients,
        pendingRequests: stats.pendingRequests,
        todayDonations: stats.todayDonations,
        todayDeliveries: stats.todayDeliveries,
        todayRequests: stats.todayRequests
      }
    });
  });

  getUsersByRole = asyncHandler(async (req, res) => {
    const { role } = req.params;
    const database = db.getDb();

    let query = '';
    if (role === 'donor') {
      query = `
        SELECT u.*, 
          (SELECT COUNT(*) FROM donations WHERE donorId = u.id) as donationCount,
          (SELECT MAX(createdAt) FROM donations WHERE donorId = u.id) as lastDonation
        FROM users u WHERE u.role = 'donor'
      `;
    } else if (role === 'volunteer') {
      query = `
        SELECT u.*, 
          (SELECT COUNT(*) FROM delivery_tasks WHERE volunteerId = u.id) as taskCount,
          (SELECT MAX(assignedAt) FROM delivery_tasks WHERE volunteerId = u.id) as lastActivity
        FROM users u WHERE u.role = 'volunteer'
      `;
    } else if (role === 'recipient') {
      query = `
        SELECT u.*, 
          (SELECT COUNT(*) FROM food_requests WHERE recipientId = u.id) as requestCount,
          (SELECT MAX(createdAt) FROM food_requests WHERE recipientId = u.id) as lastRequest
        FROM users u WHERE u.role = 'recipient'
      `;
    } else {
      return res.status(400).json({ success: false, message: 'Invalid role' });
    }

    const users = await database.all(query);

    res.status(200).json({
      success: true,
      users: users.map(user => {
        // Parse additionalInfo if it exists
        if (user.additionalInfo) {
          try {
            user.additionalInfo = JSON.parse(user.additionalInfo);
          } catch (e) {
            // Keep as is if not JSON
          }
        }
        return user;
      })
    });
  });

  updateUserStatus = asyncHandler(async (req, res) => {
    const { userId, status } = req.body;
    const database = db.getDb();

    if (!userId || !status) {
      return res.status(400).json({ success: false, message: 'User ID and status are required' });
    }

    await database.run('UPDATE users SET status = ? WHERE id = ?', [status, userId]);

    res.status(200).json({
      success: true,
      message: `User status updated to ${status}`
    });
  });
}

module.exports = new AdminController();
