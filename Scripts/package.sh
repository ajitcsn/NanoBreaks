#!/bin/zsh
set -euo pipefail

PROJECT_ROOT="${0:A:h:h}"
export DEVELOPER_DIR="/Library/Developer/CommandLineTools"
SWIFT_BIN="/Library/Developer/CommandLineTools/usr/bin/swift"
DIST_DIR="${PROJECT_ROOT}/dist"
APP_PATH="${DIST_DIR}/NanoBreaks.app"
CONTENTS_PATH="${APP_PATH}/Contents"
ICONSET_PATH="${DIST_DIR}/AppIcon.iconset"
MASTER_ICON_PATH="${PROJECT_ROOT}/Resources/Brand/NanoBreaksIcon.png"
DMG_BACKGROUND_PATH="${PROJECT_ROOT}/Resources/Brand/NanoBreaksDMGBackground.png"
STAGE_PATH="${DIST_DIR}/dmg-stage"
APP_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${PROJECT_ROOT}/Resources/Info.plist")
VOLUME_NAME="NanoBreaks ${APP_VERSION}"
MOUNT_PATH="/Volumes/${VOLUME_NAME}"
RW_DMG_PATH="${DIST_DIR}/NanoBreaks-rw.dmg"
DMG_PATH="${DIST_DIR}/NanoBreaks-${APP_VERSION}.dmg"
SIGN_IDENTITY="${NANOBREAKS_SIGN_IDENTITY:--}"
NOTARY_PROFILE="${NANOBREAKS_NOTARY_PROFILE:-}"
MOUNT_DEVICE=""

cleanup() {
    if [[ -n "${MOUNT_DEVICE}" ]]; then
        hdiutil detach "${MOUNT_DEVICE}" >/dev/null 2>&1 || true
    fi
    rm -rf "${STAGE_PATH}" "${RW_DMG_PATH}"
}
trap cleanup EXIT

cd "${PROJECT_ROOT}"
"${SWIFT_BIN}" build -c release --arch arm64 --product NanoBreaks
"${SWIFT_BIN}" build -c release --arch x86_64 --product NanoBreaks

rm -rf "${APP_PATH}" "${ICONSET_PATH}" "${STAGE_PATH}" "${RW_DMG_PATH}"
rm -f "${DMG_PATH}"
mkdir -p "${CONTENTS_PATH}/MacOS" "${CONTENTS_PATH}/Resources" "${STAGE_PATH}/.background"

lipo -create \
    "${PROJECT_ROOT}/.build/arm64-apple-macosx/release/NanoBreaks" \
    "${PROJECT_ROOT}/.build/x86_64-apple-macosx/release/NanoBreaks" \
    -output "${CONTENTS_PATH}/MacOS/NanoBreaks"
ditto "${PROJECT_ROOT}/Resources/Info.plist" "${CONTENTS_PATH}/Info.plist"

"${SWIFT_BIN}" "${PROJECT_ROOT}/Tools/IconGenerator.swift" "${MASTER_ICON_PATH}" "${ICONSET_PATH}"
iconutil --convert icns --output "${CONTENTS_PATH}/Resources/AppIcon.icns" "${ICONSET_PATH}"
rm -rf "${ICONSET_PATH}"

if [[ "${SIGN_IDENTITY}" == "-" ]]; then
    codesign --force --deep --sign - "${APP_PATH}"
else
    codesign --force --deep --options runtime --timestamp --sign "${SIGN_IDENTITY}" "${APP_PATH}"
fi
codesign --verify --deep --strict --verbose=2 "${APP_PATH}"

ditto "${APP_PATH}" "${STAGE_PATH}/NanoBreaks.app"
ditto "${CONTENTS_PATH}/Resources/AppIcon.icns" "${STAGE_PATH}/.VolumeIcon.icns"
ditto "${DMG_BACKGROUND_PATH}" "${STAGE_PATH}/.background/background.png"
ln -s /Applications "${STAGE_PATH}/Applications"
SetFile -a C "${STAGE_PATH}"

STAGE_SIZE_MB=$(du -sm "${STAGE_PATH}" | awk '{print $1}')
DMG_SIZE_MB=$((STAGE_SIZE_MB + 32))
hdiutil create \
    -srcfolder "${STAGE_PATH}" \
    -volname "${VOLUME_NAME}" \
    -fs HFS+ \
    -format UDRW \
    -size "${DMG_SIZE_MB}m" \
    "${RW_DMG_PATH}"

if [[ -e "${MOUNT_PATH}" ]]; then
    print -u2 "${MOUNT_PATH} is already mounted. Eject it and run the build again."
    exit 1
fi

ATTACH_OUTPUT=$(hdiutil attach \
    -readwrite \
    -noverify \
    -noautoopen \
    "${RW_DMG_PATH}")
MOUNT_DEVICE=$(print -r -- "${ATTACH_OUTPUT}" | awk '/Apple_HFS/ {print $1; exit}')
if [[ -z "${MOUNT_DEVICE}" ]]; then
    print -u2 "Could not identify the mounted DMG device."
    exit 1
fi

SetFile -a C "${MOUNT_PATH}"
osascript "${PROJECT_ROOT}/Scripts/style-dmg.applescript" "${VOLUME_NAME}" "NanoBreaks.app" "${MOUNT_PATH}"
sync
hdiutil detach "${MOUNT_DEVICE}"
MOUNT_DEVICE=""

hdiutil convert \
    "${RW_DMG_PATH}" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "${DMG_PATH}"

if [[ "${SIGN_IDENTITY}" == "-" ]]; then
    codesign --force --sign - "${DMG_PATH}"
else
    codesign --force --timestamp --sign "${SIGN_IDENTITY}" "${DMG_PATH}"
    if [[ -n "${NOTARY_PROFILE}" ]]; then
        xcrun notarytool submit "${DMG_PATH}" --keychain-profile "${NOTARY_PROFILE}" --wait
        xcrun stapler staple "${DMG_PATH}"
        xcrun stapler validate "${DMG_PATH}"
    fi
fi
hdiutil verify "${DMG_PATH}"

shasum -a 256 "${DMG_PATH}"
