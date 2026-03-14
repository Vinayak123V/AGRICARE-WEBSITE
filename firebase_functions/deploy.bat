@echo off
REM AgriCare Firebase Functions Deployment Script for Windows
REM This script automates the deployment of Firebase Cloud Functions

echo.
echo ========================================
echo AgriCare - Firebase Functions Deployment
echo ========================================
echo.

REM Check if Firebase CLI is installed
where firebase >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Firebase CLI not found!
    echo Installing Firebase CLI...
    npm install -g firebase-tools
)

echo Firebase CLI found
echo.

REM Check if logged in
echo Checking Firebase login...
firebase login:list

echo.
echo Select SMS Provider:
echo 1) Fast2SMS (India - Recommended)
echo 2) Twilio (Global)
echo 3) MSG91 (India)
set /p provider_choice="Enter choice (1-3): "

if "%provider_choice%"=="1" (
    set SMS_PROVIDER=FAST2SMS
    echo Selected: Fast2SMS
    set /p api_key="Enter Fast2SMS API Key: "
    firebase functions:config:set sms.fast2sms_key="%api_key%"
) else if "%provider_choice%"=="2" (
    set SMS_PROVIDER=TWILIO
    echo Selected: Twilio
    set /p twilio_sid="Enter Twilio Account SID: "
    set /p twilio_token="Enter Twilio Auth Token: "
    set /p twilio_phone="Enter Twilio Phone Number: "
    firebase functions:config:set sms.twilio_sid="%twilio_sid%"
    firebase functions:config:set sms.twilio_token="%twilio_token%"
    firebase functions:config:set sms.twilio_phone="%twilio_phone%"
) else if "%provider_choice%"=="3" (
    set SMS_PROVIDER=MSG91
    echo Selected: MSG91
    set /p msg91_key="Enter MSG91 Auth Key: "
    set /p msg91_sender="Enter MSG91 Sender ID: "
    firebase functions:config:set sms.msg91_key="%msg91_key%"
    firebase functions:config:set sms.msg91_sender="%msg91_sender%"
) else (
    echo Invalid choice
    exit /b 1
)

echo.
echo Installing dependencies...
cd functions
call npm install

echo.
echo Deploying functions...
cd ..
firebase deploy --only functions

echo.
echo ========================================
echo Deployment complete!
echo ========================================
echo.
echo Test your SMS function:
echo firebase functions:shell
echo ^> sendTestSMS({phone: '9876543210'})
echo.
echo View logs:
echo firebase functions:log
echo.
echo SMS will now be sent automatically after each booking!
echo.
pause
