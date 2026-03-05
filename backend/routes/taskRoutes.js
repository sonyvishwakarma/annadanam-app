const express = require('express');
const router = express.Router();
const taskController = require('../controllers/taskController');
const auth = require('../middleware/auth');
const authorize = require('../middleware/roleMiddleware');

// Only volunteers and admins can manage tasks
router.post('/assign', auth, authorize(['volunteer', 'admin']), taskController.assignTask.bind(taskController));
router.get('/volunteer/:volunteerId', auth, authorize(['volunteer', 'admin']), taskController.getVolunteerTasks.bind(taskController));
router.get('/stats/:volunteerId', auth, authorize(['volunteer', 'admin']), taskController.getVolunteerStats.bind(taskController));
router.post('/status', auth, authorize(['volunteer', 'admin']), taskController.updateTaskStatus.bind(taskController));

module.exports = router;
