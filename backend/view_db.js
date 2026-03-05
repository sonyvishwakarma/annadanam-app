const db = require('./database/db');

async function viewDatabase() {
  try {
    await db.connect();
    const database = db.getDb();

    console.log('\n--- 👥 USERS ---');
    const users = await database.all('SELECT name, email, phone, role, createdAt FROM users');
    users.forEach(u => console.log(`[${u.role.toUpperCase()}] ${u.name.padEnd(15)} | ${u.email.padEnd(20)} | ${u.phone || 'N/A'}`));

    console.log('\n--- 🍎 DONATIONS ---');
    const donations = await database.all('SELECT foodType, quantity, status, createdAt FROM donations');
    donations.forEach(d => console.log(`[${d.status.toUpperCase()}] ${d.foodType.padEnd(15)} | Qty: ${d.quantity}`));

    console.log('\n--- 📋 FOOD REQUESTS ---');
    const requests = await database.all('SELECT foodType, status, createdAt FROM food_requests');
    requests.forEach(r => console.log(`[${r.status.toUpperCase()}] ${r.foodType.padEnd(15)}`));

    console.log('\n--- 🚚 DELIVERY TASKS ---');
    const tasks = await database.all('SELECT status, pickupOtp, deliveryOtp FROM delivery_tasks');
    tasks.forEach(t => console.log(`[${t.status.toUpperCase()}] Pick: ${t.pickupOtp} | Del: ${t.deliveryOtp}`));

    process.exit(0);
  } catch (error) {
    console.error('Error viewing database:', error);
    process.exit(1);
  }
}

viewDatabase();
