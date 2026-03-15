const functions = require("firebase-functions");
const axios = require("axios");

// HTTPS Callable Function for SMS
exports.sendSmsCallable = functions.https.onCall(async (data, context) => {
  const { phone, message } = data;

  // Validate input
  if (!phone || !message) {
    throw new functions.https.HttpsError(
      'invalid-argument', 
      'Phone number and message are required'
    );
  }

  try {
    // Clean phone number (remove country code if present)
    let cleanPhone = phone.replace(/\D/g, '');
    if (cleanPhone.length === 11 && cleanPhone.startsWith('91')) {
      cleanPhone = cleanPhone.substring(2);
    }

    // For testing without API key - return success
    console.log('Test mode: Would send SMS to', cleanPhone, 'with message:', message);
    return { 
      success: true, 
      message: 'Test mode - SMS would be sent',
      test: true,
      phone: cleanPhone,
      messagePreview: message.substring(0, 50) + '...'
    };

    // Uncomment below when you have Fast2SMS API key
    /*
    const response = await axios.post(
      "https://www.fast2sms.com/dev/bulkV2",
      {
        route: "v3",
        message: message,
        numbers: cleanPhone,
      },
      {
        headers: {
          authorization: "YOUR_FAST2SMS_API_KEY",
        },
      }
    );

    console.log('SMS sent successfully:', response.data);
    return { 
      success: true, 
      data: response.data,
      message: 'SMS sent successfully'
    };
    */

  } catch (error) {
    console.error('SMS sending error:', error.response?.data || error.message);
    throw new functions.https.HttpsError(
      'internal', 
      'Failed to send SMS: ' + (error.response?.data?.message || error.message)
    );
  }
});
