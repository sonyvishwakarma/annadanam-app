const express = require('express');
const router = express.Router();
const requestController = require('../controllers/requestController');
const auth = require('../middleware/auth');
const authorize = require('../middleware/roleMiddleware');
const { validate, schemas } = require('../middleware/validator');

// Only recipients can create food requests
router.post(
  '/', 
  auth, 
  authorize('recipient'), 
  validate(schemas.request.create), 
  requestController.createRequest.bind(requestController)
);

// Recipients can see their own history
router.get('/recipient/:recipientId', auth, authorize(['recipient', 'admin']), requestController.getRecipientRequests.bind(requestController));
router.get('/stats/:recipientId', auth, authorize(['recipient', 'admin']), requestController.getRecipientStats.bind(requestController));

// Donors, Volunteers and admins can see available requests
router.get('/available', auth, authorize(['donor', 'volunteer', 'admin']), requestController.getAvailableRequests.bind(requestController));

// Donor can accept or decline a request
router.patch('/status', auth, authorize(['donor', 'admin']), requestController.updateRequestStatus.bind(requestController));

module.exports = router;
