/**
 * Middleware to restrict access based on user roles
 * @param {Array} roles - Array of allowed roles (e.g., ['donor', 'admin'])
 */
const authorize = (roles = []) => {
  if (typeof roles === 'string') {
    roles = [roles];
  }

  return (req, res, next) => {
    // Check if user object exists (populated by auth middleware)
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
    }

    // Check if user's role is allowed
    if (roles.length && !roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `Forbidden: Access restricted to ${roles.join(' or ')}`
      });
    }

    // Role is authorized, proceed
    next();
  };
};

module.exports = authorize;
