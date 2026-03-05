const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const auth = require('../middleware/auth');
const authorize = require('../middleware/roleMiddleware');
const { validate, schemas } = require('../middleware/validator');

router.post('/login', validate(schemas.auth.login), authController.login.bind(authController));
router.post('/register', validate(schemas.auth.register), authController.register.bind(authController));
router.get('/logout', authController.logout.bind(authController));
router.post('/change-password', auth, validate(schemas.auth.changePassword), authController.changePassword.bind(authController));
router.post('/forgot-password', validate(schemas.auth.forgotPassword), authController.forgotPassword.bind(authController));

router.get('/export-data', auth, authController.exportData.bind(authController));
router.post('/remove-sessions', auth, authController.removeActiveSessions.bind(authController));

// Only admins should be able to view all users
router.get('/users', auth, authorize('admin'), authController.getAllUsers.bind(authController));

module.exports = router;
