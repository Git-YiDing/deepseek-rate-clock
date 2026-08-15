#!/bin/zsh
set -euo pipefail

PROJECT_DIR="${0:A:h:h}"
APP_BUNDLE="${1:-$PROJECT_DIR/build/DeepSeek Rate Clock.app}"
PLIST_FILE="$APP_BUNDLE/Contents/Info.plist"
EXECUTABLE_NAME="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$PLIST_FILE")"
BINARY="$APP_BUNDLE/Contents/MacOS/$EXECUTABLE_NAME"

/usr/bin/plutil -lint "$PLIST_FILE"
/usr/bin/codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"

ARCHITECTURES="$(/usr/bin/lipo -archs "$BINARY")"
if [[ "$ARCHITECTURES" != "arm64" ]]; then
    echo "Expected arm64, got: $ARCHITECTURES" >&2
    exit 1
fi

BUILD_INFO="$(/usr/bin/xcrun vtool -show-build "$BINARY")"
if ! /usr/bin/grep -q 'minos 11\.0' <<< "$BUILD_INFO"; then
    echo "Expected minimum macOS version 11.0" >&2
    exit 1
fi

NON_SYSTEM_LIBRARIES="$(
    /usr/bin/otool -L "$BINARY" \
        | /usr/bin/tail -n +2 \
        | /usr/bin/awk '{print $1}' \
        | /usr/bin/grep -Ev '^(/System/Library/|/usr/lib/)' \
        || true
)"
if [[ -n "$NON_SYSTEM_LIBRARIES" ]]; then
    echo "Unexpected non-system libraries:" >&2
    echo "$NON_SYSTEM_LIBRARIES" >&2
    exit 1
fi

"$BINARY" --self-test
"$BINARY" --status

echo "Verification passed: $APP_BUNDLE"
