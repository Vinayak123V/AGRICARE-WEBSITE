#!/bin/bash

# Google Maps Setup Checker for AgriCare App
# This script verifies Google Maps configuration

echo "🗺️  Google Maps Configuration Checker"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check 1: Android Manifest Permissions
echo "1️⃣  Checking Android Manifest Permissions..."
if grep -q "ACCESS_FINE_LOCATION" android/app/src/main/AndroidManifest.xml 2>/dev/null; then
    echo -e "${GREEN}✅ Location permissions found${NC}"
else
    echo -e "${RED}❌ Location permissions missing${NC}"
    echo "   Add to AndroidManifest.xml:"
    echo "   <uses-permission android:name=\"android.permission.ACCESS_FINE_LOCATION\"/>"
fi
echo ""

# Check 2: Google Maps API Key in Android Manifest
echo "2️⃣  Checking Google Maps API Key in Android Manifest..."
if grep -q "com.google.android.geo.API_KEY" android/app/src/main/AndroidManifest.xml 2>/dev/null; then
    API_KEY=$(grep -A1 "com.google.android.geo.API_KEY" android/app/src/main/AndroidManifest.xml | grep "android:value" | sed 's/.*android:value="\([^"]*\)".*/\1/')
    echo -e "${GREEN}✅ API Key found: ${API_KEY:0:20}...${NC}"
else
    echo -e "${RED}❌ API Key not found in AndroidManifest.xml${NC}"
fi
echo ""

# Check 3: Google Maps API Key in web/index.html
echo "3️⃣  Checking Google Maps API Key in web/index.html..."
if grep -q "maps.googleapis.com/maps/api/js" web/index.html 2>/dev/null; then
    WEB_KEY=$(grep "maps.googleapis.com/maps/api/js" web/index.html | sed 's/.*key=\([^&"]*\).*/\1/')
    echo -e "${GREEN}✅ Web API Key found: ${WEB_KEY:0:20}...${NC}"
else
    echo -e "${RED}❌ Google Maps script not found in web/index.html${NC}"
fi
echo ""

# Check 4: pubspec.yaml dependencies
echo "4️⃣  Checking Flutter Dependencies..."
if grep -q "google_maps_flutter:" pubspec.yaml 2>/dev/null; then
    VERSION=$(grep "google_maps_flutter:" pubspec.yaml | awk '{print $2}')
    echo -e "${GREEN}✅ google_maps_flutter: ${VERSION}${NC}"
else
    echo -e "${RED}❌ google_maps_flutter not found in pubspec.yaml${NC}"
fi

if grep -q "geolocator:" pubspec.yaml 2>/dev/null; then
    VERSION=$(grep "geolocator:" pubspec.yaml | awk '{print $2}')
    echo -e "${GREEN}✅ geolocator: ${VERSION}${NC}"
else
    echo -e "${RED}❌ geolocator not found in pubspec.yaml${NC}"
fi
echo ""

# Check 5: API Key consistency
echo "5️⃣  Checking API Key Consistency..."
if [ ! -z "$API_KEY" ] && [ ! -z "$WEB_KEY" ]; then
    if [ "$API_KEY" == "$WEB_KEY" ]; then
        echo -e "${GREEN}✅ API Keys match across platforms${NC}"
    else
        echo -e "${YELLOW}⚠️  Different API Keys used for Android and Web${NC}"
        echo "   Android: ${API_KEY:0:20}..."
        echo "   Web: ${WEB_KEY:0:20}..."
        echo "   This is OK if intentional, but ensure both are properly configured"
    fi
fi
echo ""

# Instructions
echo "📋 Next Steps:"
echo "=============="
echo ""
echo "1. Enable Required APIs in Google Cloud Console:"
echo "   - Maps JavaScript API (for web)"
echo "   - Maps SDK for Android"
echo "   - Directions API"
echo "   - Geocoding API"
echo "   - Places API"
echo ""
echo "2. Configure API Key Restrictions:"
echo "   - Add package name: agricare.vinayak.com"
echo "   - Add SHA-1 fingerprint (get with: cd android && ./gradlew signingReport)"
echo ""
echo "3. Test the app:"
echo "   flutter clean"
echo "   flutter pub get"
echo "   flutter run"
echo ""
echo "4. Check for errors in console if map doesn't load"
echo ""
echo "For detailed instructions, see GOOGLE_MAPS_FIX.md"
