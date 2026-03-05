const db = require('../database/db');

class MatchingService {
  /**
   * Calculate distance between two points in KM using Haversine formula
   */
  _calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Radius of the earth in km
    const dLat = this._deg2rad(lat2 - lat1);
    const dLon = this._deg2rad(lon2 - lon1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this._deg2rad(lat1)) * Math.cos(this._deg2rad(lat2)) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c; // Distance in km
  }

  _deg2rad(deg) {
    return deg * (Math.PI / 180);
  }

  /**
   * Find potential matches for a new donation
   */
  async findMatchesForDonation(donationId) {
    try {
      const database = db.getDb();
      
      // Get the donation details
      const donation = await database.get('SELECT * FROM donations WHERE id = ?', [donationId]);
      if (!donation || donation.status !== 'pending') return [];

      // Find pending requests with the same food type
      // We can also match by isVeg if needed
      const requests = await database.all(
        'SELECT * FROM food_requests WHERE status = "pending" AND foodType = ?',
        [donation.foodType]
      );

      const matches = [];
      const MAX_DISTANCE_KM = 10; // 10km radius for matching

      for (const request of requests) {
        const distance = this._calculateDistance(
          donation.latitude, donation.longitude,
          request.latitude, request.longitude
        );

        if (distance <= MAX_DISTANCE_KM) {
          matches.push({
            request,
            distance: Math.round(distance * 10) / 10 // Round to 1 decimal
          });
        }
      }

      // Sort by distance
      return matches.sort((a, b) => a.distance - b.distance);
    } catch (error) {
      console.error('❌ Matching error:', error);
      return [];
    }
  }

  /**
   * Find potential matches for a new food request
   */
  async findMatchesForRequest(requestId) {
    try {
      const database = db.getDb();
      
      const request = await database.get('SELECT * FROM food_requests WHERE id = ?', [requestId]);
      if (!request || request.status !== 'pending') return [];

      const donations = await database.all(
        'SELECT * FROM donations WHERE status = "pending" AND foodType = ?',
        [request.foodType]
      );

      const matches = [];
      const MAX_DISTANCE_KM = 10;

      for (const donation of donations) {
        const distance = this._calculateDistance(
          request.latitude, request.longitude,
          donation.latitude, donation.longitude
        );

        if (distance <= MAX_DISTANCE_KM) {
          matches.push({
            donation,
            distance: Math.round(distance * 10) / 10
          });
        }
      }

      return matches.sort((a, b) => a.distance - b.distance);
    } catch (error) {
      console.error('❌ Matching error:', error);
      return [];
    }
  }
}

module.exports = new MatchingService();
