#!/bin/bash
# HexIdeate Mobile App Setup Script

echo "🚀 HexIdeate Mobile App Setup"
echo "=============================="
echo ""

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi

echo "✅ Flutter found: $(flutter --version)"
echo ""

# Clean previous builds
echo "🧹 Cleaning project..."
flutter clean
flutter pub get

echo ""
echo "🔨 Generating code (Freezed models, JSON serialization)..."
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Update API_BASE in lib/core/constants/api_constants.dart"
echo "2. Ensure backend gateway is running: docker compose up"
echo "3. Run: flutter run"
echo ""
echo "For debugging:"
echo "- Network requests: Check console for [📤] and [✅] symbols"
echo "- Gateway health: curl http://localhost/health"
echo "- Gateway logs: docker compose logs gateway -f"
echo ""
