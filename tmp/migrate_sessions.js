const path = require('path');
const db = require(path.join(__dirname, '..', 'backend', 'database', 'db.js'));

async function migrate() {
  try {
    await db.connect();
    const database = db.getDb();
    
    console.log('Migrating database to add tokenVersion...');
    
    try {
      await database.run('ALTER TABLE users ADD COLUMN tokenVersion INTEGER DEFAULT 1');
      console.log('✅ Added column tokenVersion to users');
    } catch (e) {
      if (e.message.includes('duplicate column name')) {
        console.log('ℹ️ Column tokenVersion already exists');
      } else {
        throw e;
      }
    }

    console.log('Migration complete!');
    process.exit(0);
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

migrate();
