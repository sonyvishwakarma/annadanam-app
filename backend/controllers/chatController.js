const db = require('../database/db');
const { v4: uuidv4 } = require('uuid');

exports.createChat = async (req, res) => {
  try {
    const { user1Id, user2Id, user1Name, user2Name } = req.body;
    const database = db.getDb();

    // Check if chat already exists
    let chat = await database.get(
      'SELECT * FROM chats WHERE (user1Id = ? AND user2Id = ?) OR (user1Id = ? AND user2Id = ?)',
      [user1Id, user2Id, user2Id, user1Id]
    );

    if (chat) {
      return res.status(200).json({ success: true, chatId: chat.id, chat });
    }

    const chatId = uuidv4();
    const createdAt = new Date().toISOString();

    await database.run(
      'INSERT INTO chats (id, user1Id, user2Id, user1Name, user2Name, lastMessage, lastMessageTime, createdAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [chatId, user1Id, user2Id, user1Name, user2Name, '', 0, createdAt]
    );

    res.status(201).json({ success: true, chatId, message: 'Chat created' });
  } catch (error) {
    console.error('Create Chat Error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

exports.sendMessage = async (req, res) => {
  try {
    const { chatId, senderId, senderName, text } = req.body;
    const database = db.getDb();
    const messageId = uuidv4();
    const timestamp = Date.now();

    await database.run(
      'INSERT INTO messages (id, chatId, senderId, senderName, text, timestamp) VALUES (?, ?, ?, ?, ?, ?)',
      [messageId, chatId, senderId, senderName, text, timestamp]
    );

    // Update chat last message
    await database.run(
      'UPDATE chats SET lastMessage = ?, lastMessageTime = ? WHERE id = ?',
      [text, timestamp, chatId]
    );

    res.status(201).json({ success: true, messageId, timestamp });
  } catch (error) {
    console.error('Send Message Error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

exports.getMessages = async (req, res) => {
  try {
    const { chatId } = req.params;
    const database = db.getDb();

    const messages = await database.all(
      'SELECT * FROM messages WHERE chatId = ? ORDER BY timestamp ASC',
      [chatId]
    );

    res.status(200).json({ success: true, messages });
  } catch (error) {
    console.error('Get Messages Error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

exports.getUserChats = async (req, res) => {
  try {
    const { userId } = req.params;
    const database = db.getDb();

    const chats = await database.all(
      'SELECT * FROM chats WHERE user1Id = ? OR user2Id = ? ORDER BY lastMessageTime DESC',
      [userId, userId]
    );

    res.status(200).json({ success: true, chats });
  } catch (error) {
    console.error('Get User Chats Error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

exports.markMessagesAsRead = async (req, res) => {
  try {
    const { chatId, userId } = req.body;
    const database = db.getDb();

    await database.run(
      'UPDATE messages SET read = 1 WHERE chatId = ? AND senderId != ? AND read = 0',
      [chatId, userId]
    );

    res.status(200).json({ success: true, message: 'Messages marked as read' });
  } catch (error) {
    console.error('Mark Read Error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};
