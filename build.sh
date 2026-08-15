#!/bin/zsh
set -euo pipefail

PROJECT_DIR="${0:A:h}"
SOURCE_FILE="$PROJECT_DIR/Sources/main.m"
PLIST_FILE="$PROJECT_DIR/Resources/Info.plist"
ICON_FILE="$PROJECT_DIR/Resources/AppIcon.icns"
BUILD_DIR="$PROJECT_DIR/build"
APP_BUNDLE="$BUILD_DIR/DeepSeek Rate Clock.app"

MAKE_RELEASE=0
case "${1:-}" in
    "") ;;
    --release) MAKE_RELEASE=1 ;;
    -h|--help)
        echo "Usage: ./build.sh [--release]"
        exit 0
        ;;
    *)
        echo "Unknown option: $1" >&2
        exit 64
        ;;
esac

for required_file in "$SOURCE_FILE" "$PLIST_FILE" "$ICON_FILE"; do
    if [[ ! -f "$required_file" ]]; then
        echo "Missing required file: $required_file" >&2
        exit 66
    fi
done

if ! /usr/bin/xcrun --find clang >/dev/null 2>&1; then
    echo "Xcode Command Line Tools are required. Run: xcode-select --install" >&2
    exit 69
fi

if [[ -L "$BUILD_DIR" || ( -e "$BUILD_DIR" && ! -d "$BUILD_DIR" ) ]]; then
    echo "Unsafe build path: $BUILD_DIR" >&2
    exit 73
fi

EXECUTABLE_NAME="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$PLIST_FILE")"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$PLIST_FILE")"

if [[ -z "$EXECUTABLE_NAME" || "$EXECUTABLE_NAME" == */* ]]; then
    echo "Invalid CFBundleExecutable: $EXECUTABLE_NAME" >&2
    exit 65
fi

if [[ -z "$VERSION" || "$VERSION" == *[^[:alnum:]._-]* ]]; then
    echo "Invalid release version: $VERSION" >&2
    exit 65
fi

STAGING_DIR="$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/deepseek-rate-clock.XXXXXX")"
trap '/bin/rm -rf -- "$STAGING_DIR"' EXIT

STAGED_APP="$STAGING_DIR/DeepSeek Rate Clock.app"
CONTENTS_DIR="$STAGED_APP/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
BINARY="$MACOS_DIR/$EXECUTABLE_NAME"

/bin/mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

/usr/bin/xcrun --sdk macosx clang \
    -arch arm64 \
    -mmacosx-version-min=11.0 \
    -fobjc-arc \
    -fblocks \
    -O2 \
    -Wall \
    -Wextra \
    "$SOURCE_FILE" \
    -framework AppKit \
    -framework Foundation \
    -o "$BINARY"

/usr/bin/install -m 644 "$PLIST_FILE" "$CONTENTS_DIR/Info.plist"
/usr/bin/install -m 644 "$ICON_FILE" "$RESOURCES_DIR/AppIcon.icns"
/bin/chmod 755 "$BINARY"

/usr/bin/plutil -lint "$CONTENTS_DIR/Info.plist"

SIGN_IDENTITY="${DEEPSEEK_CLOCK_SIGN_IDENTITY:--}"
if [[ "$SIGN_IDENTITY" == "-" ]]; then
    /usr/bin/codesign --force --sign - --timestamp=none "$STAGED_APP"
else
    /usr/bin/codesign \
        --force \
        --sign "$SIGN_IDENTITY" \
        --options runtime \
        --timestamp \
        "$STAGED_APP"
fi

/usr/bin/codesign --verify --deep --strict --verbose=2 "$STAGED_APP"
"$BINARY" --self-test

ARCHITECTURES="$(/usr/bin/lipo -archs "$BINARY")"
if [[ "$ARCHITECTURES" != "arm64" ]]; then
    echo "Unexpected architecture: $ARCHITECTURES" >&2
    exit 70
fi

/bin/mkdir -p "$BUILD_DIR"
/bin/rm -rf -- "$APP_BUNDLE"
/bin/mv "$STAGED_APP" "$APP_BUNDLE"

echo "Built: $APP_BUNDLE"

if (( MAKE_RELEASE )); then
    ARCHIVE_NAME="DeepSeek-Rate-Clock-v${VERSION}-macOS-arm64.zip"
    ARCHIVE_PATH="$BUILD_DIR/$ARCHIVE_NAME"

    /bin/rm -f -- "$ARCHIVE_PATH" "$ARCHIVE_PATH.sha256"
    /usr/bin/ditto \
        -c -k \
        --sequesterRsrc \
        --keepParent \
        "$APP_BUNDLE" \
        "$ARCHIVE_PATH"

    (
        cd "$BUILD_DIR"
        /usr/bin/shasum -a 256 "$ARCHIVE_NAME" > "$ARCHIVE_NAME.sha256"
    )

    echo "Release: $ARCHIVE_PATH"
    echo "Checksum: $ARCHIVE_PATH.sha256"
fi
