const db = require('./database/db');
const fs = require('fs');

async function check() {
    await db.connect();
    const users = await db.getDb().all('SELECT name, email, role, createdAt FROM users ORDER BY createdAt DESC LIMIT 10');
    let output = 'LATEST 10 USERS:\n';
    users.forEach(u => {
        output += `- ${u.name} (${u.email}) [${u.role}] Created: ${u.createdAt}\n`;
    });
    fs.writeFileSync('user_check.txt', output);
    console.log('Done');
    process.exit(0);
}

check();
