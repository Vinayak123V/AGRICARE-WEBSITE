/**
 * Firebase Cloud Functions for AgriCare SMS Service
 * 
 * This file contains all the cloud functions needed to send SMS
 * notifications to customers after booking.
 * 
 * Supported SMS Providers:
 * 1. Fast2SMS (India) - Recommended
 * 2. Twilio (Global)
 * 3. MSG91 (India)
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

// Initialize Firebase Admin
admin.initializeApp();

// ============================================
// CONFIGURATION - Set your SMS provider here
// ============================================

const SMS_PROVIDER = "FAST2SMS"; // Options: "FAST2SMS", "TWILIO", "MSG91"

// Fast2SMS Configuration (India)
const FAST2SMS_API_KEY = functions.config().sms?.fast2sms_key || "YOUR_FAST2SMS_API_KEY";

// Twilio Configuration (Global)
const TWILIO_ACCOUNT_SID = functions.config().sms?.twilio_sid || "YOUR_TWILIO_SID";
const TWILIO_AUTH_TOKEN = functions.config().sms?.twilio_token || "YOUR_TWILIO_TOKEN";
const TWILIO_PHONE_NUMBER = functions.config().sms?.twilio_phone || "+1234567890";

// MSG91 Configuration (India)
const MSG91_AUTH_KEY = functions.config().sms?.msg91_key || "YOUR_MSG91_KEY";
const MSG91_SENDER_ID = functions.config().sms?.msg91_sender || "AGRIXX";

// ============================================
// MAIN SMS SENDING FUNCTION
// ============================================

/**
 * Send SMS using configured provider
 * Callable function that can be invoked from Flutter app
 */
exports.sendSmsCallable = functions.https.onCall(async (data, context) => {
  const { phone, message } = data;

  // Validate input
  if (!phone || !message) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Phone number and message are required"
    );
  }

  console.log(`📱 Sending SMS to ${phone} via ${SMS_PROVIDER}`);

  try {
    let result;

    switch (SMS_PROVIDER) {
      case "FAST2SMS":
        result = await sendViaFast2SMS(phone, message);
        break;
      case "TWILIO":
        result = await sendViaTwilio(phone, message);
        break;
      case "MSG91":
        result = await sendViaMSG91(phone, message);
        break;
      default:
        throw new Error("Invalid SMS provider configured");
    }

    console.log("✅ SMS sent successfully:", result);

    // Log to Firestore for tracking
    await admin.firestore().collection("sms_logs").add({
      phone: phone,
      message: message,
      provider: SMS_PROVIDER,
      status: "sent",
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      result: result,
    });

    return {
      success: true,
      provider: SMS_PROVIDER,
      message: "SMS sent successfully",
      data: result,
    };
  } catch (error) {
    console.error("❌ SMS sending error:", error.message);

    // Log error to Firestore
    await admin.firestore().collection("sms_logs").add({
      phone: phone,
      message: message,
      provider: SMS_PROVIDER,
      status: "failed",
      error: error.message,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    throw new functions.https.HttpsError(
      "internal",
      `Failed to send SMS: ${error.message}`
    );
  }
});

// ============================================
// SMS PROVIDER IMPLEMENTATIONS
// ============================================

/**
 * Send SMS via Fast2SMS (India)
 * Best for Indian phone numbers
 */
async function sendViaFast2SMS(phone, message) {
  // Clean phone number
  let cleanPhone = phone.replace(/\D/g, "");
  if (cleanPhone.length === 12 && cleanPhone.startsWith("91")) {
    cleanPhone = cleanPhone.substring(2);
  }

  const response = await axios.post(
    "https://www.fast2sms.com/dev/bulkV2",
    {
      route: "v3",
      sender_id: "AGRIXX",
      message: message,
      language: "english",
      flash: 0,
      numbers: cleanPhone,
    },
    {
      headers: {
        authorization: FAST2SMS_API_KEY,
      },
    }
  );

  if (response.data.return === false) {
    throw new Error(response.data.message || "Fast2SMS API error");
  }

  return response.data;
}

/**
 * Send SMS via Twilio (Global)
 * Works worldwide
 */
async function sendViaTwilio(phone, message) {
  const accountSid = TWILIO_ACCOUNT_SID;
  const authToken = TWILIO_AUTH_TOKEN;
  const client = require("twilio")(accountSid, authToken);

  // Format phone number with country code
  let formattedPhone = phone;
  if (!phone.startsWith("+")) {
    formattedPhone = "+91" + phone.replace(/\D/g, "");
  }

  const twilioMessage = await client.messages.create({
    body: message,
    from: TWILIO_PHONE_NUMBER,
    to: formattedPhone,
  });

  return {
    sid: twilioMessage.sid,
    status: twilioMessage.status,
  };
}

/**
 * Send SMS via MSG91 (India)
 * Alternative for Indian numbers
 */
async function sendViaMSG91(phone, message) {
  // Clean phone number
  let cleanPhone = phone.replace(/\D/g, "");
  if (cleanPhone.length === 12 && cleanPhone.startsWith("91")) {
    cleanPhone = cleanPhone.substring(2);
  }

  const response = await axios.post(
    "https://api.msg91.com/api/v5/flow/",
    {
      sender: MSG91_SENDER_ID,
      route: "4",
      country: "91",
      sms: [
        {
          message: message,
          to: [cleanPhone],
        },
      ],
    },
    {
      headers: {
        authkey: MSG91_AUTH_KEY,
        "content-type": "application/json",
      },
    }
  );

  return response.data;
}

// ============================================
// BOOKING CONFIRMATION SMS
// ============================================

/**
 * Automatically send SMS when a new booking is created
 * This is triggered by Firestore onCreate event
 */
exports.sendBookingConfirmationSMS = functions.firestore
  .document("bookings/{bookingId}")
  .onCreate(async (snap, context) => {
    const booking = snap.data();
    const bookingId = context.params.bookingId;

    console.log(`📋 New booking created: ${bookingId}`);

    // Generate SMS message
    const message = `🌾 AgriCare - Booking Confirmation

Dear ${booking.name},

Your booking has been successfully completed!

Service: ${booking.subServiceName}
Booking ID: ${bookingId.substring(0, 8).toUpperCase()}
Date: ${booking.date}

Our service provider will contact you soon.

Thank you for choosing AgriCare!
🌱 Growing Together, Harvesting Success 🌱`;

    try {
      // Send SMS
      let result;
      switch (SMS_PROVIDER) {
        case "FAST2SMS":
          result = await sendViaFast2SMS(booking.phone, message);
          break;
        case "TWILIO":
          result = await sendViaTwilio(booking.phone, message);
          break;
        case "MSG91":
          result = await sendViaMSG91(booking.phone, message);
          break;
      }

      console.log(`✅ Booking confirmation SMS sent to ${booking.phone}`);

      // Update booking with SMS status
      await snap.ref.update({
        smsConfirmationSent: true,
        smsConfirmationTime: admin.firestore.FieldValue.serverTimestamp(),
        smsProvider: SMS_PROVIDER,
      });

      return result;
    } catch (error) {
      console.error(`❌ Failed to send booking confirmation SMS:`, error);

      // Update booking with error status
      await snap.ref.update({
        smsConfirmationSent: false,
        smsConfirmationError: error.message,
      });

      // Don't throw error - we don't want to fail the booking
      return null;
    }
  });

// ============================================
// TEST FUNCTIONS
// ============================================

/**
 * Test SMS function (no API key required)
 * Use this to test without actually sending SMS
 */
exports.sendSmsTest = functions.https.onCall(async (data, context) => {
  const { phone, message } = data;

  console.log("🧪 Test mode: Would send SMS");
  console.log("📱 To:", phone);
  console.log("📄 Message:", message);

  return {
    success: true,
    test: true,
    message: "Test mode - SMS would be sent",
    phone: phone,
    messagePreview: message,
    provider: SMS_PROVIDER,
  };
});

/**
 * Send test SMS to verify configuration
 */
exports.sendTestSMS = functions.https.onCall(async (data, context) => {
  const { phone } = data;

  if (!phone) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Phone number is required"
    );
  }

  const testMessage = `🧪 AgriCare - Test SMS

This is a test message from AgriCare SMS service.

If you receive this, SMS integration is working correctly! 🎉

Time: ${new Date().toLocaleString("en-IN", { timeZone: "Asia/Kolkata" })}

Provider: ${SMS_PROVIDER}`;

  try {
    let result;
    switch (SMS_PROVIDER) {
      case "FAST2SMS":
        result = await sendViaFast2SMS(phone, testMessage);
        break;
      case "TWILIO":
        result = await sendViaTwilio(phone, testMessage);
        break;
      case "MSG91":
        result = await sendViaMSG91(phone, testMessage);
        break;
    }

    return {
      success: true,
      message: "Test SMS sent successfully",
      provider: SMS_PROVIDER,
      result: result,
    };
  } catch (error) {
    throw new functions.https.HttpsError(
      "internal",
      `Test SMS failed: ${error.message}`
    );
  }
});

// ============================================
// UTILITY FUNCTIONS
// ============================================

/**
 * Get SMS sending statistics
 */
exports.getSmsStats = functions.https.onCall(async (data, context) => {
  const logs = await admin
    .firestore()
    .collection("sms_logs")
    .orderBy("timestamp", "desc")
    .limit(100)
    .get();

  const stats = {
    total: logs.size,
    sent: 0,
    failed: 0,
    recent: [],
  };

  logs.forEach((doc) => {
    const log = doc.data();
    if (log.status === "sent") stats.sent++;
    if (log.status === "failed") stats.failed++;
    stats.recent.push({
      phone: log.phone,
      status: log.status,
      timestamp: log.timestamp,
      provider: log.provider,
    });
  });

  return stats;
});
