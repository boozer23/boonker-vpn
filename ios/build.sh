#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
IOS_DIR="$ROOT_DIR/ios/BoonkerVPN"
SOURCE_HTML="$ROOT_DIR/outputs/vpn-prototype.html"
BUNDLE_HTML="$IOS_DIR/BoonkerVPN/WebPrototype/vpn-prototype.html"
DERIVED_DATA=${DERIVED_DATA:-/tmp/boonker-web}

cp "$SOURCE_HTML" "$BUNDLE_HTML"

grep -q 'id="serverSearch"' "$SOURCE_HTML"
grep -q '>Favorites<' "$SOURCE_HTML"
grep -q '>Recent<' "$SOURCE_HTML"
grep -q 'class="city-option"' "$SOURCE_HTML"
grep -q 'class="tunnel__meta"' "$SOURCE_HTML"
grep -q 'white-space: nowrap' "$SOURCE_HTML"

xcodebuild \
  -project "$IOS_DIR/BoonkerVPN.xcodeproj" \
  -scheme BoonkerVPN \
  -sdk iphonesimulator \
  -configuration Debug \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  build

APP="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/BoonkerVPN.app"
cmp -s "$SOURCE_HTML" "$APP/vpn-prototype.html"
printf '%s\n' "Built and verified: $APP"
