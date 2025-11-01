#!/bin/bash

# TreatTracker - Setup Verification Script
# This script checks if your environment is properly configured

echo "🎃 TreatTracker Setup Verification"
echo "=================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Flutter
echo "📱 Checking Flutter..."
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    echo -e "${GREEN}✓${NC} Flutter installed: $FLUTTER_VERSION"
else
    echo -e "${RED}✗${NC} Flutter not found. Install from: https://flutter.dev"
    exit 1
fi

# Check Firebase CLI
echo ""
echo "🔥 Checking Firebase CLI..."
if command -v firebase &> /dev/null; then
    FIREBASE_VERSION=$(firebase --version)
    echo -e "${GREEN}✓${NC} Firebase CLI installed: $FIREBASE_VERSION"
else
    echo -e "${RED}✗${NC} Firebase CLI not found. Install: npm install -g firebase-tools"
    exit 1
fi

# Check FlutterFire CLI
echo ""
echo "🔧 Checking FlutterFire CLI..."
if command -v flutterfire &> /dev/null; then
    echo -e "${GREEN}✓${NC} FlutterFire CLI installed"
else
    echo -e "${YELLOW}!${NC} FlutterFire CLI not found. Installing..."
    dart pub global activate flutterfire_cli
fi

# Check for firebase_options.dart
echo ""
echo "🔑 Checking Firebase configuration..."
if [ -f "lib/firebase_options.dart" ]; then
    echo -e "${GREEN}✓${NC} firebase_options.dart exists"
    
    # Check if it contains actual values or placeholders
    if grep -q "YOUR_API_KEY" lib/firebase_options.dart; then
        echo -e "${YELLOW}!${NC} firebase_options.dart contains placeholders"
        echo "  Run: flutterfire configure --platforms=web"
    else
        echo -e "${GREEN}✓${NC} firebase_options.dart is configured"
    fi
else
    echo -e "${RED}✗${NC} firebase_options.dart not found"
    echo "  Run: flutterfire configure --platforms=web"
    exit 1
fi

# Check if firebase_options.dart is git-ignored
echo ""
echo "🔒 Checking security..."
if git check-ignore -q lib/firebase_options.dart 2>/dev/null; then
    echo -e "${GREEN}✓${NC} firebase_options.dart is properly git-ignored"
else
    echo -e "${RED}✗${NC} WARNING: firebase_options.dart is NOT git-ignored!"
    echo "  This is a security risk. Check .gitignore"
fi

# Check dependencies
echo ""
echo "📦 Checking dependencies..."
if [ -f "pubspec.lock" ]; then
    echo -e "${GREEN}✓${NC} Dependencies installed"
else
    echo -e "${YELLOW}!${NC} Dependencies not installed"
    echo "  Run: flutter pub get"
fi

# Final summary
echo ""
echo "=================================="
echo "✨ Setup Status"
echo "=================================="

ISSUES=0

if [ ! -f "lib/firebase_options.dart" ]; then
    echo -e "${RED}✗${NC} Missing firebase_options.dart - Run: flutterfire configure --platforms=web"
    ((ISSUES++))
elif grep -q "YOUR_API_KEY" lib/firebase_options.dart; then
    echo -e "${YELLOW}!${NC} Firebase config has placeholders - Run: flutterfire configure --platforms=web"
    ((ISSUES++))
fi

if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✓${NC} All checks passed! Ready to run:"
    echo ""
    echo "  flutter run -d chrome"
    echo ""
else
    echo -e "${YELLOW}!${NC} Please fix the issues above before running the app"
    exit 1
fi
