// backend/seed.js - Creates test users for all roles
const db = require('./database/db');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');

const testUsers = [
  {
    name: 'Test Donor',
    email: 'donor@test.com',
    phone: '9000000001',
    role: 'donor',
    password: 'Test@1234',
  },
  {
    name: 'Test Volunteer',
    email: 'volunteer@test.com',
    phone: '9000000002',
    role: 'volunteer',
    password: 'Test@1234',
  },
  {
    name: 'Test Recipient',
    email: 'recipient@test.com',
    phone: '9000000003',
    role: 'recipient',
    password: 'Test@1234',
  },
  {
    name: 'Test Admin',
    email: 'admin@test.com',
    phone: '9000000004',
    role: 'admin',
    password: 'Test@1234',
  },
];

async function seed() {
  try {
    await db.connect();
    const database = db.getDb();
    
    // Clear existing test users
    await database.run('DELETE FROM users WHERE email LIKE "%@test.com" OR phone LIKE "900000000%"');
    console.log('🧹 Cleared existing test users');

    const salt = await bcrypt.genSalt(10);
    let created = 0;
    let skipped = 0;

    for (const u of testUsers) {
      // Skip if user already exists
      const existing = await database.get(
        'SELECT id FROM users WHERE email = ? OR phone = ?',
        [u.email, u.phone]
      );
      if (existing) {
        console.log(`⚠️  Skipped (already exists): ${u.email}`);
        skipped++;
        continue;
      }

      const hashedPassword = await bcrypt.hash(u.password, salt);
      const id = uuidv4();
      const now = new Date().toISOString();

      await database.run(
        `INSERT INTO users (id, name, email, phone, password, role, verified, createdAt, additionalInfo)
         VALUES (?, ?, ?, ?, ?, ?, 1, ?, ?)`,
        [id, u.name, u.email, u.phone, hashedPassword, u.role, now, JSON.stringify({})]
      );

      console.log(`✅ Created: ${u.name} | ${u.email} | role: ${u.role}`);
      created++;
    }

    console.log(`\n🎉 Done! Created: ${created}, Skipped: ${skipped}`);
    console.log('\n📋 Test Credentials (password for all: Test@1234)');
    console.log('─────────────────────────────────────────────────');
    console.log('Role       | Email               | Phone');
    console.log('───────────|─────────────────────|────────────');
    console.log('Donor      | donor@test.com      | 9000000001');
    console.log('Volunteer  | volunteer@test.com  | 9000000002');
    console.log('Recipient  | recipient@test.com  | 9000000003');
    console.log('Admin      | admin@test.com      | 9000000004');
    console.log('─────────────────────────────────────────────────');
    console.log('Existing user: sony@gmail.com (password unknown - reset if needed)\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Seed error:', error);
    process.exit(1);
  }
}

seed();
