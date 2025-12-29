# Firebase Setup for Real OTP Authentication

## 🚀 **Real OTP Implementation Complete!**

Your app now uses **Firebase Phone Authentication** instead of mock OTP. This provides secure, real SMS-based OTP verification.

## 📋 **Setup Instructions**

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or select existing project
3. Enable **Phone Authentication**:
   - Go to Authentication → Sign-in method
   - Enable "Phone" provider

### 2. Configure Android App
1. In Firebase Console → Project Settings → General
2. Add Android app with package name: `com.example.abc`
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

### 3. Configure iOS App (Optional)
1. Add iOS app with bundle ID: `com.example.abc`
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/GoogleService-Info.plist`

### 4. Update Firebase Configuration
Edit `lib/firebase_options.dart` with your Firebase project details:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-actual-android-api-key',
  appId: 'your-actual-android-app-id',
  messagingSenderId: 'your-sender-id',
  projectId: 'your-project-id',
  storageBucket: 'your-project-id.appspot.com',
);
```

### 5. Enable Phone Authentication in Firebase
- Go to Firebase Console → Authentication → Sign-in method
- Enable Phone provider
- Add test phone numbers (optional for development)

## 🔧 **How It Works Now**

### **Before (Mock OTP):**
```dart
// Generated random 6-digit number
_farmerSentOtp = (100000 + rnd.nextInt(900000)).toString();
```

### **After (Real OTP):**
```dart
// Firebase sends real SMS to user's phone
await otpService.sendOTP(phoneNumber);
```

## 📱 **User Experience**

### **Phone Number Input:**
- Users must enter **international format**: `+91XXXXXXXXXX`
- Validation prevents invalid formats
- Clear error messages for wrong formats

### **OTP Process:**
1. **Send OTP** → Firebase sends SMS to phone
2. **Enter OTP** → User enters 6-digit code
3. **Verify** → Firebase validates the code
4. **Success** → User logged in securely

### **Security Features:**
- ✅ **Rate limiting**: Max 3 OTP requests per minute
- ✅ **OTP expiry**: 5-minute validity
- ✅ **Phone validation**: International format required
- ✅ **Error handling**: Clear error messages
- ✅ **Auto-verification**: Works on Android devices

## 🧪 **Testing**

### **Test Phone Numbers (Development):**
In Firebase Console → Authentication → Sign-in method → Phone:
- Add test numbers like: `+91 9999999999`
- Set test OTP code: `123456`

### **Production:**
- Remove test numbers
- Enable reCAPTCHA for web verification
- Configure SMS costs in Firebase

## 🚨 **Important Notes**

### **SMS Costs:**
- Firebase Phone Auth charges for SMS delivery
- Check [Firebase Pricing](https://firebase.google.com/pricing)

### **Phone Number Format:**
- Always use international format: `+{country_code}{number}`
- Examples: `+91 9876543210`, `+1 5551234567`

### **Fallback:**
- If Firebase fails, implement backup SMS service
- Consider using services like Twilio for production

## 🔄 **Migration from Mock to Real OTP**

The app automatically switches from mock to real OTP when:
1. ✅ Firebase is properly configured
2. ✅ Phone numbers are in correct format
3. ✅ Firebase project has Phone Auth enabled

## 📞 **Support**

If you encounter issues:
1. Check Firebase Console for error logs
2. Verify phone number format
3. Ensure Firebase project is properly configured
4. Check device network connectivity

---

## 🗄️ **Firebase Database Structure**

The app uses the following Firestore collections to store data. All events and user actions are logged in the `audit_trail` collection for tracking and analytics.

### **Collections Overview**

#### **users** (Single Document: `current_user`)
- Stores the currently logged-in user's session data
- Fields: `type` (encrypted), `id` (encrypted)

#### **vets**
- Stores veterinarian credentials and registration data
- Document ID: Vet ID (unique identifier)
- Fields: `username` (encrypted), `passwordHash` (encrypted hash with salt)

#### **farmers**
- Stores farmer profiles and registration data
- Document ID: Phone number (unique identifier)
- Fields: Personal details, location, compliance status, livestock count, etc.

#### **livestock**
- Stores animal data and health records
- Document ID: Animal ID (unique identifier)
- Fields: Owner ID, species, health status, medication history, withdrawal periods, etc.

#### **districts**
- Stores district-level aggregated data
- Document ID: District name
- Fields: Farmer count, vet count, livestock count, compliance rates, areas

#### **prescriptions**
- Stores veterinary prescriptions and medication records
- Auto-generated Document ID
- Fields: Animal ID, medication, veterinarian, issue date, status

#### **alerts**
- Stores system alerts and notifications
- Auto-generated Document ID
- Fields: Type, message, location, priority, timestamp, read status

#### **kpis** (Single Document: `current`)
- Stores key performance indicators
- Fields: Total livestock, active withdrawal count, compliance rate, pending reviews

#### **translations** (Single Document: `current`)
- Stores multilingual text translations
- Fields: `en`, `hi`, `ta` (maps of translation keys to values)

#### **events** (Hierarchical Collection)
- **Events and Actions Storage**: All user actions and system events are stored hierarchically
- Structure: `events/{entity_type}/actions/{auto_id}`
- Documents in `events` collection represent entity types (farmer, vet, animal, etc.)
- Each entity type document has an `actions` subcollection containing individual action records
- Action document fields: `entity_type`, `entity_id`, `action`, `user_type`, `user_id`, `timestamp`, `details`

### **Events and Actions Structure**

All events and actions are stored in the `audit_trail` collection with the following structure:

```json
{
  "entity_type": "farmer|vet|animal|prescription|alert",
  "entity_id": "unique identifier of the entity",
  "action": "create|update|delete|login|logout|view|export|etc.",
  "user_type": "farmer|vet|seller|admin",
  "user_id": "user identifier",
  "timestamp": "server timestamp",
  "details": {
    "additional": "contextual data",
    "ip_address": "if available",
    "device_info": "if available"
  }
}
```

### **Example Events/Actions Structure**

Events are organized hierarchically in Firebase:

```
events/
├── vet/
│   └── actions/
│       ├── {auto_id}: {entity_type: "vet", action: "login", entity_id: "vet_id", ...}
│       └── {auto_id}: {entity_type: "vet", action: "logout", entity_id: "vet_id", ...}
├── animal/
│   └── actions/
│       ├── {auto_id}: {entity_type: "animal", action: "create", entity_id: "animal_id", ...}
│       └── {auto_id}: {entity_type: "animal", action: "update", entity_id: "animal_id", ...}
├── prescription/
│   └── actions/
│       └── {auto_id}: {entity_type: "prescription", action: "create", entity_id: "prescription_id", ...}
└── alert/
    └── actions/
        └── {auto_id}: {entity_type: "alert", action: "view", entity_id: "alert_id", ...}
```

This structure groups all actions related to each entity type under their respective event documents.

### **Data Security**

- Sensitive data (usernames, passwords) are encrypted using AES encryption
- Passwords are hashed with salt for additional security
- User sessions are encrypted in Firestore and SharedPreferences

### **Offline Support**

- Critical data is cached in SharedPreferences for offline access
- Firebase data syncs when connection is restored
- Vet credentials are available offline after initial login

---

## 🎉 **Ready to Use!**

Your app now has **production-ready OTP authentication** with Firebase Phone Authentication! 🚀📱