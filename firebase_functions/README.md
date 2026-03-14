# AgriCare Firebase Cloud Functions

## 🚀 Quick Start

### Windows Users
```bash
deploy.bat
```

### Mac/Linux Users
```bash
chmod +x deploy.sh
./deploy.sh
```

## 📋 Manual Setup

### 1. Install Firebase CLI
```bash
npm install -g firebase-tools
```

### 2. Login
```bash
firebase login
```

### 3. Initialize (if not done)
```bash
firebase init functions
```

### 4. Configure SMS Provider

**Fast2SMS (Recommended for India):**
```bash
firebase functions:config:set sms.fast2sms_key="YOUR_API_KEY"
```

**Twilio (Global):**
```bash
firebase functions:config:set sms.twilio_sid="YOUR_SID"
firebase functions:config:set sms.twilio_token="YOUR_TOKEN"
firebase functions:config:set sms.twilio_phone="+1234567890"
```

**MSG91 (India):**
```bash
firebase functions:config:set sms.msg91_key="YOUR_KEY"
firebase functions:config:set sms.msg91_sender="AGRIXX"
```

### 5. Deploy
```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

## 🧪 Testing

### Test SMS Function
```bash
firebase functions:shell
> sendTestSMS({phone: "9876543210"})
```

### View Logs
```bash
firebase functions:log
```

## 📱 Available Functions

1. **sendSmsCallable** - Send SMS (callable from app)
2. **sendBookingConfirmationSMS** - Auto-send on booking (Firestore trigger)
3. **sendTestSMS** - Test SMS sending
4. **getSmsStats** - Get SMS statistics

## 🔧 Configuration

Edit `index.js` to change SMS provider:
```javascript
const SMS_PROVIDER = "FAST2SMS"; // or "TWILIO" or "MSG91"
```

## 📊 Monitoring

- **Firebase Console:** https://console.firebase.google.com
- **Functions Logs:** `firebase functions:log`
- **Firestore:** Check `sms_logs` collection

## 💡 How It Works

1. User creates booking in app
2. Booking saved to Firestore
3. Cloud Function automatically triggered
4. SMS sent via configured provider
5. Booking updated with SMS status
6. SMS log saved for tracking

## 🆘 Support

See `FIREBASE_SMS_SETUP_COMPLETE.md` for detailed documentation.

## ✅ Checklist

- [ ] Firebase CLI installed
- [ ] Logged into Firebase
- [ ] SMS provider configured
- [ ] Functions deployed
- [ ] Test SMS sent
- [ ] Booking SMS working

## 🎉 Success!

Once deployed, SMS will be sent automatically after every booking!
