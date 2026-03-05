# Annadanam API Documentation (Production Level)

## Base URL
`http://localhost:3000/api`

## Security Features
- **Helmet**: Security headers enabled.
- **Rate Limiting**: 100 requests per 15 minutes per IP.
- **Param Pollution**: HPP enabled.
- **CORS**: Enabled for all origins (`*`).
- **File Uploads**: Max file size 5MB (Images only).

---

## 1. Authentication (`/auth`)

### Register
`POST /auth/register`
- **Body**: `name`, `email` OR `phoneNumber`, `role`, `password`.
- **Validation**: Joi schema enforced.

### Login
`POST /auth/login`
- **Body**: `email` OR `phone`, `password`.
- **Returns**: JWT Token and User data.

### Send OTP
`POST /auth/send-otp`
- **Body**: `phoneNumber` OR `email`.
- **Note**: Supports Twilio/SendGrid or Mock mode.

---

## 2. Donations (`/donations`)

### Create Donation
`POST /donations/`
- **Auth**: Required (Role: `donor`)
- **Type**: `multipart/form-data`
- **Fields**: 
  - `image` (File): Food photo
  - `donorId`, `foodType`, `category`, `quantity`, `servings`, `description`, `isVeg`, `pickupAddress`, `pickupDate`, `pickupTime`, `specialInstructions`, `hasAllergens`, `allergens` (JSON string/array), `latitude`, `longitude`.

### Get Donor Stats
`GET /donations/stats/:donorId`
- **Returns**: Total donations, quantity, active donations, and people fed estimate.

---

## 3. Food Requests (`/food-requests`)

### Create Request
`POST /food-requests/`
- **Auth**: Required (Role: `recipient`)
- **Body**: `recipientId`, `foodType`, `category`, `quantityRequired`, `servingsRequired`, `address`, `latitude`, `longitude`.

---

## 4. Delivery Tasks (`/tasks`)

### Assign Task
`POST /tasks/`
- **Auth**: Required (Role: `volunteer`/`admin`)
- **Body**: `donationId`, `requestId`, `volunteerId`.
- **Returns**: `pickupOtp`, `deliveryOtp`.

### Verify Pickup
`POST /tasks/verify-pickup`
- **Body**: `taskId`, `pickupOtp`.

### Verify Delivery
`POST /tasks/verify-delivery`
- **Body**: `taskId`, `deliveryOtp`.

---

## 5. Development Utilities
- **Seed Data**: `node seed.js` (Creates test users).
- **Uploads**: Accessible at `http://localhost:3000/uploads/[filename]`.
