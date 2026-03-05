const sqlite3 = require('sqlite3');
const { open } = require('sqlite');
const path = require('path');
const fs = require('fs');

class Database {
  constructor() {
    this.db = null;
  }

  async connect() {
    try {
      const dbDir = path.join(__dirname, '..', 'db');
      if (!fs.existsSync(dbDir)) {
        fs.mkdirSync(dbDir, { recursive: true });
      }

      this.db = await open({
        filename: path.join(dbDir, 'annadanam.sqlite'),
        driver: sqlite3.Database
      });

      console.log('✅ SQLite database connected');
      
      // Enable foreign key support
      await this.db.run('PRAGMA foreign_keys = ON');
      
      await this.createTables();
      return this.db;
    } catch (error) {
      console.error('❌ Database connection error:', error);
      throw error;
    }
  }

  async createTables() {
    // Users table
    await this.db.exec(`
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        phone TEXT UNIQUE,
        role TEXT NOT NULL,
        password TEXT,
        status TEXT DEFAULT 'active',
        verified INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        lastLogin TEXT,
        additionalInfo TEXT
      )
    `);

    // Safe migration: add status column if it doesn't exist (for existing databases)
    try {
      await this.db.run("ALTER TABLE users ADD COLUMN status TEXT DEFAULT 'active'");
    } catch (e) {
      // Column already exists — this is expected on fresh or already-migrated databases
    }

    // Donations table
    await this.db.exec(`
      CREATE TABLE IF NOT EXISTS donations (
        id TEXT PRIMARY KEY,
        donorId TEXT NOT NULL,
        foodType TEXT NOT NULL,
        category TEXT,
        quantity TEXT,
        servings TEXT,
        description TEXT,
        isVeg INTEGER,
        imageUrl TEXT,
        pickupAddress TEXT,
        pickupDate TEXT,
        pickupTime TEXT,
        specialInstructions TEXT,
        hasAllergens INTEGER,
        allergens TEXT,
        latitude REAL,
        longitude REAL,
        status TEXT DEFAULT 'pending',
        createdAt TEXT NOT NULL,
        FOREIGN KEY (donorId) REFERENCES users (id)
      )
    `);

    // Food Requests table
    await this.db.exec(`
      CREATE TABLE IF NOT EXISTS food_requests (
        id TEXT PRIMARY KEY,
        recipientId TEXT NOT NULL,
        foodType TEXT NOT NULL,
        category TEXT,
        quantityRequired TEXT,
        servingsRequired TEXT,
        description TEXT,
        isVeg INTEGER,
        address TEXT,
        latitude REAL,
        longitude REAL,
        status TEXT DEFAULT 'pending',
        donorId TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (recipientId) REFERENCES users (id),
        FOREIGN KEY (donorId) REFERENCES users (id)
      )
    `);

    // Safe migration: add donorId and category to food_requests if they don't exist
    try {
      await this.db.run('ALTER TABLE food_requests ADD COLUMN donorId TEXT');
      console.log('✅ Added donorId column to food_requests');
    } catch (e) {
      if (!e.message.includes('duplicate column name')) {
        console.warn('⚠️ Migration warning (donorId):', e.message);
      }
    }

    try {
      await this.db.run('ALTER TABLE food_requests ADD COLUMN category TEXT');
      console.log('✅ Added category column to food_requests');
    } catch (e) {
      if (!e.message.includes('duplicate column name')) {
        console.warn('⚠️ Migration warning (category):', e.message);
      }
    }

    // Verify columns
    const columns = await this.db.all('PRAGMA table_info(food_requests)');
    console.log('📊 food_requests columns:', columns.map(c => c.name).join(', '));
    
    // Delivery Tasks table
    await this.db.exec(`
      CREATE TABLE IF NOT EXISTS delivery_tasks (
        id TEXT PRIMARY KEY,
        donationId TEXT,
        requestId TEXT,
        volunteerId TEXT NOT NULL,
        status TEXT DEFAULT 'assigned',
        assignedAt TEXT NOT NULL,
        pickedUpAt TEXT,
        deliveredAt TEXT,
        FOREIGN KEY (donationId) REFERENCES donations (id),
        FOREIGN KEY (requestId) REFERENCES food_requests (id),
        FOREIGN KEY (volunteerId) REFERENCES users (id)
      )
    `);

    // Migration for delivery_tasks: Make donationId nullable
    const taskTableInfo = await this.db.all('PRAGMA table_info(delivery_tasks)');
    const donationIdCol = taskTableInfo.find(c => c.name === 'donationId');
    if (donationIdCol && donationIdCol.notnull === 1) {
      console.log('🔄 Migrating delivery_tasks to allow NULL donationId...');
      try {
        await this.db.run('PRAGMA foreign_keys=OFF');
        await this.db.run('BEGIN TRANSACTION');
        
        // 1. Create new table
        await this.db.run(`
          CREATE TABLE delivery_tasks_new (
            id TEXT PRIMARY KEY,
            donationId TEXT,
            requestId TEXT,
            volunteerId TEXT NOT NULL,
            status TEXT DEFAULT 'assigned',
            assignedAt TEXT NOT NULL,
            pickedUpAt TEXT,
            deliveredAt TEXT,
            FOREIGN KEY (donationId) REFERENCES donations (id),
            FOREIGN KEY (requestId) REFERENCES food_requests (id),
            FOREIGN KEY (volunteerId) REFERENCES users (id)
          )
        `);
        
        // 2. Copy data
        await this.db.run(`
          INSERT INTO delivery_tasks_new (id, donationId, requestId, volunteerId, status, assignedAt, pickedUpAt, deliveredAt)
          SELECT id, donationId, requestId, volunteerId, status, assignedAt, pickedUpAt, deliveredAt FROM delivery_tasks
        `);
        
        // 3. Drop old table
        await this.db.run('DROP TABLE delivery_tasks');
        
        // 4. Rename new table
        await this.db.run('ALTER TABLE delivery_tasks_new RENAME TO delivery_tasks');
        
        await this.db.run('COMMIT');
        await this.db.run('PRAGMA foreign_keys=ON');
        console.log('✅ Refactored delivery_tasks table successfully');
      } catch (e) {
        await this.db.run('ROLLBACK');
        console.error('❌ Failed to refactor delivery_tasks:', e.message);
      }
    }

    // Chats table
    await this.db.exec(`
      CREATE TABLE IF NOT EXISTS chats (
        id TEXT PRIMARY KEY,
        user1Id TEXT NOT NULL,
        user2Id TEXT NOT NULL,
        user1Name TEXT,
        user2Name TEXT,
        lastMessage TEXT,
        lastMessageTime INTEGER,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (user1Id) REFERENCES users (id),
        FOREIGN KEY (user2Id) REFERENCES users (id)
      )
    `);

    // Messages table
    await this.db.exec(`
      CREATE TABLE IF NOT EXISTS messages (
        id TEXT PRIMARY KEY,
        chatId TEXT NOT NULL,
        senderId TEXT NOT NULL,
        senderName TEXT,
        text TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        read INTEGER DEFAULT 0,
        FOREIGN KEY (chatId) REFERENCES chats (id),
        FOREIGN KEY (senderId) REFERENCES users (id)
      )
    `);

    // --- Create Indexes for Performance ---
    
    // Index for messages to quickly fetch by chatId and sort by timestamp
    await this.db.exec(`CREATE INDEX IF NOT EXISTS idx_messages_chatid_timestamp ON messages(chatId, timestamp)`);
    
    // Index for chats to quickly find by user IDs
    await this.db.exec(`CREATE INDEX IF NOT EXISTS idx_chats_user1 ON chats(user1Id)`);
    await this.db.exec(`CREATE INDEX IF NOT EXISTS idx_chats_user2 ON chats(user2Id)`);
    
    // Unique index to prevent duplicate chats between same two users
    // This ensures (Alice, Bob) and (Alice, Bob) can't coexist
    // Note: Our controller handles the logic for (Bob, Alice)
    await this.db.exec(`CREATE UNIQUE INDEX IF NOT EXISTS idx_chats_participants_unique ON chats(user1Id, user2Id)`);
    
    // Index for tasks to quickly find by volunteer or donor
    await this.db.exec(`CREATE INDEX IF NOT EXISTS idx_tasks_volunteer ON delivery_tasks(volunteerId)`);
    await this.db.exec(`CREATE INDEX IF NOT EXISTS idx_tasks_donation ON delivery_tasks(donationId)`);

    console.log('✅ Database tables and indexes created/verified');
  }

  getDb() {
    if (!this.db) {
      throw new Error('Database not initialized');
    }
    return this.db;
  }
}

module.exports = new Database();