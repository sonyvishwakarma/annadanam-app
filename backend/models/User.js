const { v4: uuidv4 } = require('uuid');

class User {
  constructor(userData = {}) {
    this.id = userData.id || uuidv4();
    this.name = userData.name || '';
    this.email = userData.email || '';
    this.phone = userData.phone || '';
    this.role = userData.role || 'donor';
    this.password = userData.password || null;
    this.verified = userData.verified !== undefined ? userData.verified : 1;
    this.createdAt = userData.createdAt || new Date().toISOString();
    this.lastLogin = userData.lastLogin || null;
    this.additionalInfo = userData.additionalInfo || null;
  }

  toDB() {
    return {
      id: this.id,
      name: this.name,
      email: this.email,
      phone: this.phone,
      role: this.role,
      password: this.password,
      verified: this.verified ? 1 : 0,
      createdAt: this.createdAt,
      lastLogin: this.lastLogin,
      additionalInfo: (this.additionalInfo && typeof this.additionalInfo === 'object') ? JSON.stringify(this.additionalInfo) : this.additionalInfo
    };
  }

  static fromDB(row) {
    if (!row) return null;
    
    return {
      id: row.id,
      name: row.name,
      email: row.email,
      phone: row.phone,
      role: row.role,
      verified: row.verified === 1,
      createdAt: row.createdAt,
      lastLogin: row.lastLogin,
      additionalInfo: row.additionalInfo ? JSON.parse(row.additionalInfo) : {}
    };
  }
}

module.exports = User;