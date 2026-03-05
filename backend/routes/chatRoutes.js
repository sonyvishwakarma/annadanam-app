const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');

router.post('/create', chatController.createChat);
router.post('/send', chatController.sendMessage);
router.get('/messages/:chatId', chatController.getMessages);
router.get('/user/:userId', chatController.getUserChats);
router.post('/mark-read', chatController.markMessagesAsRead);

module.exports = router;
