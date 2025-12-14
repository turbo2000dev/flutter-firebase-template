#!/bin/bash
# Helper script to generate base64-encoded Firebase config for GitHub secrets

set -e

echo "🔧 Firebase Config Secret Generator"
echo "===================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the root directory
ROOT_DIR=$(git rev-parse --show-toplevel)

# Android google-services.json
echo "📱 Android Configuration"
echo "------------------------"
ANDROID_FILE="$ROOT_DIR/android/app/google-services.json"

if [ -f "$ANDROID_FILE" ]; then
    echo -e "${BLUE}File found:${NC} $ANDROID_FILE"
    echo ""
    echo "GitHub Secret Name: GOOGLE_SERVICES_JSON_BASE64"
    echo ""
    echo -e "${GREEN}Secret Value (copy everything below):${NC}"
    echo "---START---"
    base64 -i "$ANDROID_FILE" | tr -d '\n'
    echo ""
    echo "---END---"
    echo ""
else
    echo "❌ File not found: $ANDROID_FILE"
    echo ""
fi

# iOS GoogleService-Info.plist
echo "🍎 iOS Configuration"
echo "--------------------"
IOS_FILE="$ROOT_DIR/ios/Runner/GoogleService-Info.plist"

if [ -f "$IOS_FILE" ]; then
    echo -e "${BLUE}File found:${NC} $IOS_FILE"
    echo ""
    echo "GitHub Secret Name: GOOGLE_SERVICE_INFO_PLIST_BASE64"
    echo ""
    echo -e "${GREEN}Secret Value (copy everything below):${NC}"
    echo "---START---"
    base64 -i "$IOS_FILE" | tr -d '\n'
    echo ""
    echo "---END---"
    echo ""
else
    echo "❌ File not found: $IOS_FILE"
    echo ""
fi

echo "📝 Next Steps"
echo "-------------"
echo "1. Go to: https://github.com/turbo2000dev/retirement-app/settings/secrets/actions"
echo "2. Click 'New repository secret'"
echo "3. Add each secret with the name and value shown above"
echo "4. Make sure to copy the ENTIRE base64 string (from ---START--- to ---END---)"
echo ""
echo "⚠️  Important: Copy only the base64 string, NOT the ---START--- or ---END--- markers"
echo ""
