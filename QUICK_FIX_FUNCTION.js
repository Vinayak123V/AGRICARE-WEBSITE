const functions = require("firebase-functions");

// Simple test function (no API key needed)
exports.sendSmsCallable = functions.https.onCall(async (data, context) => {
  const { phone, message } = data;

  console.log('Test mode: Would send SMS to', phone, 'with message:', message);
  
  return { 
    success: true, 
    message: 'Test mode - SMS would be sent',
    test: true,
    phone: phone,
    messagePreview: message.substring(0, 50) + '...'
  };
});
