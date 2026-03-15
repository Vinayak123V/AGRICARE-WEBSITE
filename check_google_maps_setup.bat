@echo off
REM Google Maps Setup Checker for AgriCare App (Windows)
REM This script verifies Google Maps configuration

echo.
echo ========================================
echo   Google Maps Configuration Checker
echo ========================================
echo.

REM Check 1: Android Manifest Permissions
echo 1. Checking Android Manifest Permissions...
findstr /C:"ACCESS_FINE_LOCATION" android\ios\lib\android\app\src\main\AndroidManifest.xml >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Location permissions found
) else (
    echo [ERROR] Location permissions missing
    echo    Add to AndroidManifest.xml:
    echo    ^<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/^>
)
echo.

REM Check 2: Google Maps API Key in Android Manifest
echo 2. Checking Google Maps API Key in Android Manifest...
findstr /C:"com.google.android.geo.API_KEY" android\ios\lib\android\app\src\main\AndroidManifest.xml >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] API Key found in AndroidManifest.xml
) else (
    echo [ERROR] API Key not found in AndroidManifest.xml
)
echo.

REM Check 3: Google Maps API Key in web/index.html
echo 3. Checking Google Maps API Key in web/index.html...
findstr /C:"maps.googleapis.com/maps/api/js" android\ios\lib\web\index.html >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Google Maps script found in web/index.html
) else (
    echo [ERROR] Google Maps script not found in web/index.html
)
echo.

REM Check 4: pubspec.yaml dependencies
echo 4. Checking Flutter Dependencies...
findstr /C:"google_maps_flutter:" android\ios\lib\pubspec.yaml >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] google_maps_flutter found in pubspec.yaml
) else (
    echo [ERROR] google_maps_flutter not found in pubspec.yaml
)

findstr /C:"geolocator:" android\ios\lib\pubspec.yaml >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] geolocator found in pubspec.yaml
) else (
    echo [ERROR] geolocator not found in pubspec.yaml
)
echo.

REM Instructions
echo ========================================
echo   Next Steps
echo ========================================
echo.
echo 1. Enable Required APIs in Google Cloud Console:
echo    - Maps JavaScript API (for web)
echo    - Maps SDK for Android
echo    - Directions API
echo    - Geocoding API
echo    - Places API
echo.
echo 2. Configure API Key Restrictions:
echo    - Add package name: agricare.vinayak.com
echo    - Add SHA-1 fingerprint
echo      Get with: cd android\ios\lib\android ^&^& gradlew signingReport
echo.
echo 3. Test the app:
echo    flutter clean
echo    flutter pub get
echo    flutter run
echo.
echo 4. Check for errors in console if map doesn't load
echo.
echo For detailed instructions, see GOOGLE_MAPS_FIX.md
echo.
pause
