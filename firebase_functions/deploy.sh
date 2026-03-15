#!/bin/bash

# AgriCare Firebase Functions Deployment Script
# This script automates the deployment of Firebase Cloud Functions

echo "🌾 AgriCare - Firebase Functions Deployment"
echo "==========================================="
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null
then
    echo "❌ Firebase CLI not found!"
    echo "📦 Installing Firebase CLI..."
    npm install -g firebase-tools
fi

echo "✅ Firebase CLI found"
echo ""

# Check if logged in
echo "🔐 Checking Firebase login..."
firebase login:list

echo ""
echo "📋 Select SMS Provider:"
echo "1) Fast2SMS (India - Recommended)"
echo "2) Twilio (Global)"
echo "3) MSG91 (India)"
read -p "Enter choice (1-3): " provider_choice

case $provider_choice in
    1)
        SMS_PROVIDER="FAST2SMS"
        echo "📱 Selected: Fast2SMS"
        read -p "Enter Fast2SMS API Key: " api_key
        firebase functions:config:set sms.fast2sms_key="$api_key"
        ;;
    2)
        SMS_PROVIDER="TWILIO"
        echo "📱 Selected: Twilio"
        read -p "Enter Twilio Account SID: " twilio_sid
        read -p "Enter Twilio Auth Token: " twilio_token
        read -p "Enter Twilio Phone Number: " twilio_phone
        firebase functions:config:set sms.twilio_sid="$twilio_sid"
        firebase functions:config:set sms.twilio_token="$twilio_token"
        firebase functions:config:set sms.twilio_phone="$twilio_phone"
        ;;
    3)
        SMS_PROVIDER="MSG91"
        echo "📱 Selected: MSG91"
        read -p "Enter MSG91 Auth Key: " msg91_key
        read -p "Enter MSG91 Sender ID: " msg91_sender
        firebase functions:config:set sms.msg91_key="$msg91_key"
        firebase functions:config:set sms.msg91_sender="$msg91_sender"
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "📦 Installing dependencies..."
cd functions
npm install

echo ""
echo "🚀 Deploying functions..."
cd ..
firebase deploy --only functions

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🧪 Test your SMS function:"
echo "firebase functions:shell"
echo "> sendTestSMS({phone: '9876543210'})"
echo ""
echo "📊 View logs:"
echo "firebase functions:log"
echo ""
echo "🎉 SMS will now be sent automatically after each booking!"
