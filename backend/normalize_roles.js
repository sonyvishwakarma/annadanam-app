const db = require('./database/db');

async function normalizeRoles() {
  try {
    await db.connect();
    const database = db.getDb();

    console.log('Normalizing roles in database...');

    // Standardize 'Food Donor' to 'donor'
    const res1 = await database.run("UPDATE users SET role = 'donor' WHERE role = 'Food Donor'");
    console.log(`Updated ${res1.changes} 'Food Donor' entries to 'donor'`);

    // Standardize 'Food Recipient' to 'recipient'
    const res2 = await database.run("UPDATE users SET role = 'recipient' WHERE role = 'Food Recipient'");
    console.log(`Updated ${res2.changes} 'Food Recipient' entries to 'recipient'`);

    // Standardize 'Volunteer' to 'volunteer' (if any case issues)
    const res3 = await database.run("UPDATE users SET role = 'volunteer' WHERE LOWER(role) = 'volunteer'");
    console.log(`Updated ${res3.changes} volunteer entries`);

    console.log('Role normalization complete.');
    process.exit(0);
  } catch (error) {
    console.error('Error normalizing roles:', error);
    process.exit(1);
  }
}

normalizeRoles();
