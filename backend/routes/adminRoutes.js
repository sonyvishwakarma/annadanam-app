const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const auth = require('../middleware/auth');
const authorize = require('../middleware/roleMiddleware');

// All admin routes require admin role
router.use(auth);
router.use(authorize('admin'));

router.get('/stats', adminController.getGlobalStats);
router.get('/users/:role', adminController.getUsersByRole);
router.post('/user-status', adminController.updateUserStatus);

module.exports = router;
