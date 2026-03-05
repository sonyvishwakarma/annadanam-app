const db = require('./database/db');

async function resetDatabase() {
  try {
    console.log('🔄 Connecting to database...');
    await db.connect();
    const database = db.getDb();

    console.log('🗑️  Deleting all data from tables...');
    
    // Disable foreign key checks temporarily for clearing
    await database.run('PRAGMA foreign_keys = OFF');
    
    await database.run('DELETE FROM delivery_tasks');
    console.log('✅ Cleared delivery_tasks');
    
    await database.run('DELETE FROM messages');
    console.log('✅ Cleared messages');
    
    await database.run('DELETE FROM chats');
    console.log('✅ Cleared chats');
    
    await database.run('DELETE FROM food_requests');
    console.log('✅ Cleared food_requests');
    
    await database.run('DELETE FROM donations');
    console.log('✅ Cleared donations');
    
    await database.run('DELETE FROM users');
    console.log('✅ Cleared users');
    
    await database.run('PRAGMA foreign_keys = ON');

    console.log('\n✨ Database has been fully reset. You can now start fresh!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error resetting database:', error);
    process.exit(1);
  }
}

resetDatabase();
