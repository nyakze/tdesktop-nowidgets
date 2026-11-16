#!/bin/bash
# FORK: merge the per-arch macOS build trees into one universal app bundle.
#
# The Swift translation module cannot be built as a fat binary in a single
# pass, so CI configures and builds arm64 and x86_64 separately — the recipe
# of Telegram/build/build_mac.py — and this script merges the results: every
# Mach-O is lipo-merged, the thin Swift runtime is replaced with the universal
# one from swift-stdlib-tool, everything else is copied from the arm64 tree.
#
# Usage: merge-mac-universal.sh <arm64-release-dir> <x86_64-release-dir> <output-dir>
set -e

ARM64="$1"
X86_64="$2"
OUT="$3"
APP_NAME=NoWidgetGram.app

mkdir -p "$OUT"
rm -rf "$OUT/$APP_NAME"
cp -R "$ARM64/$APP_NAME" "$OUT/$APP_NAME"

count_archs() {
    lipo -archs "$1" 2>/dev/null | wc -w | tr -d ' '
}

while IFS= read -r -d '' found; do
    rel="${found#./}"
    case "$rel" in
        Contents/Frameworks/libswift*.dylib)
            continue
            ;;
    esac
    a="$ARM64/$APP_NAME/$rel"
    b="$X86_64/$APP_NAME/$rel"
    dst="$OUT/$APP_NAME/$rel"
    if [ ! -f "$b" ]; then
        echo "missing in the x86_64 build: $rel" >&2
        exit 1
    fi
    if [ "$(count_archs "$a")" = "0" ]; then
        continue
    fi
    a_in="$a"
    b_in="$b"
    if [ "$(count_archs "$a")" != "1" ]; then
        lipo "$a" -thin arm64 -output "$dst.a64"
        a_in="$dst.a64"
    fi
    if [ "$(count_archs "$b")" != "1" ]; then
        lipo "$b" -thin x86_64 -output "$dst.x64"
        b_in="$dst.x64"
    fi
    lipo -create "$a_in" "$b_in" -output "$dst.merged"
    rm -f "$dst.a64" "$dst.x64"
    mv "$dst.merged" "$dst"
    strip -x "$dst"
done < <(cd "$ARM64/$APP_NAME" && find . -type f -print0)

rm -f "$OUT/$APP_NAME"/Contents/Frameworks/libswift*.dylib
xcrun swift-stdlib-tool --copy --platform macosx \
    --scan-executable "$OUT/$APP_NAME/Contents/MacOS/NoWidgetGram" \
    --destination "$OUT/$APP_NAME/Contents/Frameworks"

ARCHS=$(lipo -archs "$OUT/$APP_NAME/Contents/MacOS/NoWidgetGram")
case "$ARCHS" in
    "x86_64 arm64"|"arm64 x86_64") ;;
    *)
        echo "universal verification failed: $ARCHS" >&2
        exit 1
        ;;
esac

if [ -f "$OUT/$APP_NAME/Contents/Frameworks/Updater" ]; then
    cp "$OUT/$APP_NAME/Contents/Frameworks/Updater" "$OUT/Updater"
fi

echo "universal app ready: $OUT/$APP_NAME ($ARCHS)"
