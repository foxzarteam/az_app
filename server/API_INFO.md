# API Endpoints List

Base URL: `http://localhost:3000/api`

---

## Users APIs

### 1. Get User by Mobile
**GET** `/api/users/mobile/:mobile`  
Get user details by mobile number

### 2. Create User
**POST** `/api/users`  
Create a new user account

### 3. Upsert User
**PUT** `/api/users/upsert`  
Create or update user (insert if not exists, update if exists)

### 4. Update MPIN
**PATCH** `/api/users/mobile/:mobile/mpin`  
Update user's MPIN (4-digit PIN)

### 5. Update Login Status
**PATCH** `/api/users/mobile/:mobile/login-status`  
Update user's login status (logged in/out)

### 6. Update Profile
**PATCH** `/api/users/mobile/:mobile/profile`  
Update user profile (name, email)

---

## OTP APIs

### 7. Send OTP
**POST** `/api/otp/send`  
Send OTP to mobile number for verification

### 8. Verify OTP
**POST** `/api/otp/verify`  
Verify OTP code sent to mobile number

---

## Leads APIs

### 9. Create Lead
**POST** `/api/leads`  
Create a new lead (loan application)

**Request Body:**
```json
{
  "pan": "ABCDE1234F",
  "mobileNumber": "9876543210",
  "fullName": "John Doe",
  "email": "john@example.com",
  "pincode": "110001",
  "requiredAmount": 50000,
  "category": "personal_loan",
  "userId": "optional-user-uuid"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "lead-uuid",
    "pan": "ABCDE1234F",
    "mobile_number": "9876543210",
    "full_name": "John Doe",
    "category": "personal_loan",
    "status": "pending",
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

### 10. Get Leads by User
**GET** `/api/leads/user/:userId`  
Get all leads for a specific user

### 11. Get Leads by Category
**GET** `/api/leads/user/:userId/category/:category`  
Get leads filtered by category (personal_loan, insurance, credit_card)

---

## Banners APIs

### 12. Get Active Banners
**GET** `/api/banners`  
Get all active banners

### 13. Get Banners by Category
**GET** `/api/banners/category/:category`  
Get banners filtered by category (carousel, promo, kyc, offer)