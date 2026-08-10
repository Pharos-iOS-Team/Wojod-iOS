#!/usr/bin/env bash
# =============================================================================
# package_variant.sh
#
# Takes a pre-built base .xcarchive and produces a fully signed, variant-
# specific IPA without recompiling any Swift source code.
#
# What it does:
#   1. Copies the base .xcarchive to a variant-specific working copy
#   2. Patches Info.plist (bundle ID, display name, URLs, version)
#   3. Swaps the GoogleService-Info.plist for the variant
#   4. Re-compiles the asset catalog (actool) with the variant's app icon
#      and brand images (CoursesLogo, Splash, small)
#   5. Injects the compiled Assets.car into the archive
#   6. Re-signs the app bundle and packages a final IPA
#   7. Validates the IPA bundle ID matches what was patched
#
# Usage:
#   release/package_variant.sh <CONFIGURATION> <BASE_ARCHIVE_PATH> <OUTPUT_DIR>
#
# Arguments:
#   CONFIGURATION      One of: Release | Hassan-Elnaggar | Perfection-in-Physics |
#                               Royal-Medicine | Square-Center
#   BASE_ARCHIVE_PATH  Path to the pre-built .xcarchive (absolute or relative)
#   OUTPUT_DIR         Directory where the variant .xcarchive and IPA are written
#
# Required env vars (passed by the Fastlane package_variant lane):
#   PROFILE_UUID       Provisioning profile UUID for this variant
#   PROFILE_PATH       Downloaded provisioning profile path
#   VARIANT_BUNDLE_ID  Bundle identifier for this variant
#
# Optional:
#   TEAM_ID            Apple Developer Team ID (default: 46AX569373)
#   BUILD_NUMBER       Overrides CFBundleVersion in the patched Info.plist
# =============================================================================

set -euo pipefail

# Print the exact line and command whenever any step fails so CI logs
# always show where the script broke, not just the final exit code.
trap 'echo "SCRIPT FAILED at line ${LINENO}: command \"${BASH_COMMAND}\" exited with status $?" >&2' ERR

# ─── Arguments ────────────────────────────────────────────────────────────────
CONFIGURATION="${1:?Usage: package_variant.sh <CONFIGURATION> <BASE_ARCHIVE> <OUTPUT_DIR>}"
BASE_ARCHIVE="${2:?Missing BASE_ARCHIVE_PATH}"
OUTPUT_DIR="${3:?Missing OUTPUT_DIR}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ─── Project paths ─────────────────────────────────────────────────────────────
XCCONFIG="${PROJECT_ROOT}/App/SupportingFiles/Configs/${CONFIGURATION}.xcconfig"
GOOGLE_SERVICES_DIR="${PROJECT_ROOT}/App/SupportingFiles/GoogleServiceInfo"
VARIANT_XCASSETS="${PROJECT_ROOT}/App/Resources/Assets/${CONFIGURATION}.xcassets"
IMAGES_XCASSETS="${PROJECT_ROOT}/App/Resources/Images.xcassets"
COLORS_XCASSETS="${PROJECT_ROOT}/App/Resources/Colors.xcassets"

# ─── Output paths ──────────────────────────────────────────────────────────────
VARIANT_ARCHIVE="${OUTPUT_DIR}/${CONFIGURATION}.xcarchive"
IPA_OUTPUT="${OUTPUT_DIR}/${CONFIGURATION}"
LOG_FILE="${OUTPUT_DIR}/${CONFIGURATION}.package.log"

TEAM_ID="${TEAM_ID:-46AX569373}"

# ─── Validation ────────────────────────────────────────────────────────────────
[[ -f "${XCCONFIG}" ]]     || { echo "ERROR: xcconfig not found: ${XCCONFIG}"; exit 1; }
[[ -d "${BASE_ARCHIVE}" ]] || { echo "ERROR: Base archive not found: ${BASE_ARCHIVE}"; exit 1; }

mkdir -p "${OUTPUT_DIR}"
: > "${LOG_FILE}"
exec > >(tee -a "${LOG_FILE}") 2>&1

echo "→ Logging to ${LOG_FILE}"

# ─── Helper: read a value from xcconfig ────────────────────────────────────────
# Handles both "KEY = VALUE" and "KEY=VALUE", skips comment lines.
xcconfig_value() {
  local key="$1"
  grep -E "^[[:space:]]*${key}[[:space:]]*=" "${XCCONFIG}" \
    | tail -1 \
    | sed 's/[^=]*=[[:space:]]*//' \
    | tr -d '\r\n'
}

# xcconfig uses "$() /" to embed a literal "/" in a URL to avoid xcconfig
# treating it as a path separator. e.g. "https:/$()/" becomes "https://".
unescape_xcconfig_url() {
  # Replace all occurrences of "$()/" with "/"
  echo "$1" | sed 's|\$()\/|/|g'
}

# ─── Read variant config ───────────────────────────────────────────────────────
BUNDLE_ID="$(xcconfig_value PRODUCT_BUNDLE_IDENTIFIER)"
APP_DISPLAY_NAME="$(xcconfig_value APP_DISPLAY_NAME)"
APP_VERSION="$(xcconfig_value APP_VERSION)"
RAW_ROOT_URL="$(xcconfig_value ROOT_URL)"
RAW_BASE_URL="$(xcconfig_value BASE_URL)"
RAW_CHAT_URL="$(xcconfig_value CHAT_BASE_URL)"

ROOT_URL="$(unescape_xcconfig_url "${RAW_ROOT_URL}")"
BASE_URL="$(unescape_xcconfig_url "${RAW_BASE_URL}")"
CHAT_BASE_URL="$(unescape_xcconfig_url "${RAW_CHAT_URL}")"

[[ -n "${BUNDLE_ID}" ]]        || { echo "ERROR: PRODUCT_BUNDLE_IDENTIFIER missing in ${XCCONFIG}"; exit 1; }
[[ -n "${APP_DISPLAY_NAME}" ]] || { echo "ERROR: APP_DISPLAY_NAME missing in ${XCCONFIG}"; exit 1; }
[[ -n "${APP_VERSION}" ]]      || { echo "ERROR: APP_VERSION missing in ${XCCONFIG}"; exit 1; }

echo "╔════════════════════════════════════════════════════════════╗"
printf  "║  Packaging variant : %-38s║\n" "${CONFIGURATION}"
printf  "║  Bundle ID         : %-38s║\n" "${BUNDLE_ID}"
printf  "║  Display name      : %-38s║\n" "${APP_DISPLAY_NAME}"
printf  "║  Version           : %-38s║\n" "${APP_VERSION}"
printf  "║  Base URL          : %-38s║\n" "${BASE_URL}"
echo "╚════════════════════════════════════════════════════════════╝"

# ─── Step 1: Copy base archive to variant-specific path ───────────────────────
echo ""
echo "→ [1/6] Copying base archive..."
rm -rf "${VARIANT_ARCHIVE}"
cp -R "${BASE_ARCHIVE}" "${VARIANT_ARCHIVE}"

# Locate the .app bundle inside the archive
APP_BUNDLE="$(find "${VARIANT_ARCHIVE}/Products" -maxdepth 3 -name "*.app" | head -1)"
[[ -n "${APP_BUNDLE}" ]] || { echo "ERROR: No .app bundle found inside archive."; exit 1; }
echo "  → Found: $(basename "${APP_BUNDLE}")"

INFO_PLIST="${APP_BUNDLE}/Info.plist"
ARCHIVE_INFO="${VARIANT_ARCHIVE}/Info.plist"

# ─── Step 2: Patch the app bundle's Info.plist ────────────────────────────────
echo "→ [2/6] Patching Info.plist..."
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier '${BUNDLE_ID}'"           "${INFO_PLIST}"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName '${APP_DISPLAY_NAME}'"   "${INFO_PLIST}"
/usr/libexec/PlistBuddy -c "Set :APP_DISPLAY_NAME '${APP_DISPLAY_NAME}'"      "${INFO_PLIST}"
/usr/libexec/PlistBuddy -c "Set :BASE_URL '${BASE_URL}'"                      "${INFO_PLIST}"
/usr/libexec/PlistBuddy -c "Set :ROOT_URL '${ROOT_URL}'"                      "${INFO_PLIST}"
/usr/libexec/PlistBuddy -c "Set :CHAT_BASE_URL '${CHAT_BASE_URL}'"            "${INFO_PLIST}"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString '${APP_VERSION}'" "${INFO_PLIST}"

# Override CFBundleVersion (build number) if provided
if [[ -n "${BUILD_NUMBER:-}" ]]; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion '${BUILD_NUMBER}'" "${INFO_PLIST}"
fi

# Keep the archive-level metadata consistent with the patched app bundle.
if /usr/libexec/PlistBuddy -c "Print :ApplicationProperties:CFBundleIdentifier" \
     "${ARCHIVE_INFO}" &>/dev/null; then
  /usr/libexec/PlistBuddy \
    -c "Set :ApplicationProperties:CFBundleIdentifier '${BUNDLE_ID}'" \
    "${ARCHIVE_INFO}"
fi

echo "  → CFBundleIdentifier = ${BUNDLE_ID}"

# ─── Step 3: Swap GoogleService-Info.plist ────────────────────────────────────
echo "→ [3/6] Updating GoogleService-Info.plist..."
GOOGLE_SERVICES_SRC="${GOOGLE_SERVICES_DIR}/${CONFIGURATION}/GoogleService-Info.plist"
if [[ -f "${GOOGLE_SERVICES_SRC}" ]]; then
  cp "${GOOGLE_SERVICES_SRC}" "${APP_BUNDLE}/GoogleService-Info.plist"
  echo "  → Copied from ${CONFIGURATION}/"
else
  echo "  ⚠ No GoogleService-Info.plist for '${CONFIGURATION}', keeping base archive copy"
fi

# ─── Step 4: Re-compile the asset catalog for this variant ────────────────────
echo "→ [4/6] Recompiling asset catalog (actool)..."

# Map configuration name to the app icon set name.
# Royal-Medicine and Square-Center use hardcoded names in the pbxproj;
# the others use the CONFIGURATION variable expansion pattern.
case "${CONFIGURATION}" in
  Release)         APP_ICON_NAME="AppIcon" ;;
  Royal-Medicine)  APP_ICON_NAME="AppIcon-Royal-Medicine" ;;
  Square-Center)   APP_ICON_NAME="AppIcon-Square-Center" ;;
  *)               APP_ICON_NAME="AppIcon-${CONFIGURATION}" ;;
esac
echo "  → App icon set: ${APP_ICON_NAME}"

# Build a temporary xcassets that merges the shared Images.xcassets with
# this variant's Common assets. This avoids modifying the source tree.
TEMP_DIR="$(mktemp -d)"
TEMP_IMAGES="${TEMP_DIR}/Images.xcassets"
cp -R "${IMAGES_XCASSETS}" "${TEMP_IMAGES}"

VARIANT_COMMON="${VARIANT_XCASSETS}/Common"
if [[ -d "${VARIANT_COMMON}" ]]; then
  rm -rf "${TEMP_IMAGES}/Common"
  mkdir -p "${TEMP_IMAGES}/Common"
  cp -R "${VARIANT_COMMON}/"* "${TEMP_IMAGES}/Common/"
  COMMON_COUNT="$(find "${VARIANT_COMMON}" -name "*.imageset" -type d | wc -l | tr -d ' ')"
  echo "  → Merged ${COMMON_COUNT} variant-specific image set(s) from ${CONFIGURATION}.xcassets/Common"
else
  echo "  ⚠ No Common assets found for '${CONFIGURATION}', using base Images.xcassets/Common"
fi

ASSETS_OUT="${TEMP_DIR}/compiled"
mkdir -p "${ASSETS_OUT}"

# Deployment target and device families come from the Xcode target settings:
#   IPHONEOS_DEPLOYMENT_TARGET = 15  (target-level setting)
#   TARGETED_DEVICE_FAMILY     = 1,2 (iPhone + iPad)
DEPLOYMENT_TARGET="15.0"

echo "  → Running actool (platform=iphoneos, min-sdk=${DEPLOYMENT_TARGET})..."
xcrun actool \
  --platform iphoneos \
  --minimum-deployment-target "${DEPLOYMENT_TARGET}" \
  --target-device iphone \
  --target-device ipad \
  --app-icon "${APP_ICON_NAME}" \
  --accent-color AccentColor \
  --compress-pngs \
  --output-format human-readable-text \
  --notices --warnings \
  --output-partial-info-plist "${ASSETS_OUT}/partial_info.plist" \
  --compile "${ASSETS_OUT}" \
  "${TEMP_IMAGES}" \
  "${COLORS_XCASSETS}" \
  2>&1 | grep -E "error:|warning:" || true

# ─── Step 5: Inject compiled assets into the archive ──────────────────────────
echo "→ [5/6] Injecting compiled assets..."

if [[ -f "${ASSETS_OUT}/Assets.car" ]]; then
  cp "${ASSETS_OUT}/Assets.car" "${APP_BUNDLE}/Assets.car"
  CAR_SIZE="$(du -h "${APP_BUNDLE}/Assets.car" | cut -f1)"
  echo "  → Replaced Assets.car (${CAR_SIZE})"
else
  echo "  ⚠ actool did not produce Assets.car; keeping base archive's copy"
fi

# Update CFBundleIconName so iOS picks up the correct icon from Assets.car.
# CFBundleIcons / CFBundleIcons~ipad already exist in Info.plist from the
# base archive compilation — only the name needs to change.
/usr/libexec/PlistBuddy -c "Set :CFBundleIconName '${APP_ICON_NAME}'" \
  "${INFO_PLIST}" 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Add :CFBundleIconName string '${APP_ICON_NAME}'" \
  "${INFO_PLIST}" 2>/dev/null || true
echo "  → CFBundleIconName = ${APP_ICON_NAME}"

rm -rf "${TEMP_DIR}"

# ─── Step 6: Re-sign the .app and package as IPA ─────────────────────────────
# codesign is used directly instead of xcodebuild -exportArchive.
# xcodebuild validates every entitlement in the Xcode project's .entitlements
# file against the provisioning profile and fails if the profile does not
# include a capability (e.g. Push Notifications) even when the capability is
# unused by the variant. The direct codesign approach signs with exactly the
# entitlements the downloaded profile provides, so no capability mismatch
# can occur.
echo "→ [6/6] Re-signing and packaging IPA..."

[[ -n "${PROFILE_UUID:-}" ]]      || { echo "ERROR: PROFILE_UUID not set. Call via the Fastlane package_variant lane."; exit 1; }
[[ -n "${VARIANT_BUNDLE_ID:-}" ]] || { echo "ERROR: VARIANT_BUNDLE_ID not set."; exit 1; }

# Prefer the exact path returned by Fastlane for this variant's downloaded
# profile. Fall back to the standard installed location only if needed.
if [[ -n "${PROFILE_PATH:-}" ]] && [[ -f "${PROFILE_PATH}" ]]; then
  RESOLVED_PROFILE_PATH="${PROFILE_PATH}"
else
  RESOLVED_PROFILE_PATH="${HOME}/Library/MobileDevice/Provisioning Profiles/${PROFILE_UUID}.mobileprovision"
fi

[[ -f "${RESOLVED_PROFILE_PATH}" ]] || { echo "ERROR: Provisioning profile not found for UUID ${PROFILE_UUID}"; exit 1; }
echo "  → Profile UUID: ${PROFILE_UUID}"
echo "  → Profile: ${RESOLVED_PROFILE_PATH}"

# Decode the mobileprovision to a real plist file first.
# On CI, piping security cms output directly into PlistBuddy can produce
# an empty stdin read even when the profile itself is valid.
DECODED_PROFILE_PLIST="${OUTPUT_DIR}/${CONFIGURATION}_profile.plist"
ENTITLEMENTS_PLIST="${OUTPUT_DIR}/${CONFIGURATION}_entitlements.plist"
security cms -D -i "${RESOLVED_PROFILE_PATH}" > "${DECODED_PROFILE_PLIST}"
[[ -s "${DECODED_PROFILE_PLIST}" ]] || { echo "ERROR: Decoded provisioning profile plist is empty: ${DECODED_PROFILE_PLIST}"; exit 1; }

/usr/libexec/PlistBuddy -x -c "Print :Entitlements" "${DECODED_PROFILE_PLIST}" > "${ENTITLEMENTS_PLIST}"
[[ -s "${ENTITLEMENTS_PLIST}" ]] || { echo "ERROR: Extracted entitlements plist is empty: ${ENTITLEMENTS_PLIST}"; exit 1; }
echo "  → Entitlements extracted from profile"

PROFILE_TEAM_ID="$(/usr/libexec/PlistBuddy -c "Print :TeamIdentifier:0" "${DECODED_PROFILE_PLIST}" 2>/dev/null || true)"
SIGNING_TEAM_ID="${PROFILE_TEAM_ID:-${TEAM_ID}}"

IDENTITY_MATCHES="$(security find-identity -v -p codesigning 2>/dev/null \
  | sed -nE 's/^[[:space:]]*[0-9]+\) ([0-9A-F]+) "([^"]+)".*/\1\t\2/p' \
  | grep -F $'\tApple Distribution:' \
  | grep -F "(${SIGNING_TEAM_ID})" || true)"

SIGNING_IDENTITY_HASH="$(printf '%s\n' "${IDENTITY_MATCHES}" | sed -n '1s/\t.*//p')"
SIGNING_IDENTITY_NAME="$(printf '%s\n' "${IDENTITY_MATCHES}" | sed -n '1s/^[^\t]*\t//p')"
IDENTITY_COUNT="$(printf '%s\n' "${IDENTITY_MATCHES}" | sed '/^$/d' | wc -l | tr -d ' ')"

[[ -n "${SIGNING_IDENTITY_HASH}" ]] || {
  echo "ERROR: No Apple Distribution signing identity found for team ${SIGNING_TEAM_ID}";
  security find-identity -v -p codesigning 2>/dev/null | grep 'Apple Distribution' || true;
  exit 1;
}

if [[ "${IDENTITY_COUNT}" != "1" ]]; then
  echo "  ⚠ Found ${IDENTITY_COUNT} matching Apple Distribution identity/identities for team ${SIGNING_TEAM_ID}; using the first one"
fi

echo "  → Signing identity: ${SIGNING_IDENTITY_NAME}"
echo "  → Signing hash: ${SIGNING_IDENTITY_HASH}"

# Embed the provisioning profile into the .app bundle
cp "${RESOLVED_PROFILE_PATH}" "${APP_BUNDLE}/embedded.mobileprovision"
echo "  → embedded.mobileprovision installed"

sign_item() {
  local path="$1"
  echo "  → Signing: ${path}"
  codesign --force --sign "${SIGNING_IDENTITY_HASH}" --timestamp=none "${path}"
}

# Sign nested frameworks first (codesign requires inside-out order)
if [[ -d "${APP_BUNDLE}/Frameworks" ]]; then
  while IFS= read -r fw; do
    sign_item "${fw}"
  done < <(find "${APP_BUNDLE}/Frameworks" \( -name "*.framework" -o -name "*.dylib" \) -print | sort -r)
  echo "  → Frameworks signed"
fi

# Sign app extensions (PlugIns) if any are present
if [[ -d "${APP_BUNDLE}/PlugIns" ]]; then
  while IFS= read -r ext; do
    sign_item "${ext}"
  done < <(find "${APP_BUNDLE}/PlugIns" -name "*.appex" -print)
  echo "  → Extensions signed"
fi

# Sign the main .app bundle with the profile's entitlements
echo "  → Signing app bundle: ${APP_BUNDLE}"
codesign --force --sign "${SIGNING_IDENTITY_HASH}" \
  --entitlements "${ENTITLEMENTS_PLIST}" \
  --timestamp=none \
  "${APP_BUNDLE}"
echo "  → App bundle signed"
rm -f "${ENTITLEMENTS_PLIST}" "${DECODED_PROFILE_PLIST}"

# Verify the new signature (non-fatal; warnings are printed but do not abort)
codesign --verify --verbose "${APP_BUNDLE}" 2>&1 || \
  echo "  ⚠ codesign --verify returned non-zero; review the output above"

# Package the signed .app into a flat IPA (standard Payload/ structure)
rm -rf "${IPA_OUTPUT}"
mkdir -p "${IPA_OUTPUT}/Payload"
echo "  → Copying signed app bundle into Payload/"
cp -R "${APP_BUNDLE}" "${IPA_OUTPUT}/Payload/"
echo "  → Creating IPA archive ${CONFIGURATION}.ipa"
(cd "${IPA_OUTPUT}" && zip -qr "${CONFIGURATION}.ipa" Payload/)
rm -rf "${IPA_OUTPUT}/Payload"

# ─── Validate the produced IPA ────────────────────────────────────────────────
IPA_FILE="${IPA_OUTPUT}/${CONFIGURATION}.ipa"
[[ -f "${IPA_FILE}" ]] || { echo "ERROR: IPA was not produced at ${IPA_FILE}"; exit 1; }

IPA_SIZE="$(du -h "${IPA_FILE}" | cut -f1)"

IPA_INFO_PLIST_PATH="$(unzip -Z1 "${IPA_FILE}" "Payload/*.app/Info.plist" 2>/dev/null | head -1)"
[[ -n "${IPA_INFO_PLIST_PATH}" ]] || { echo "ERROR: Could not locate Info.plist inside ${IPA_FILE}"; exit 1; }

IPA_INFO_PLIST="${OUTPUT_DIR}/${CONFIGURATION}_ipa_info.plist"
unzip -p "${IPA_FILE}" "${IPA_INFO_PLIST_PATH}" > "${IPA_INFO_PLIST}"
IPA_BUNDLE_ID="$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "${IPA_INFO_PLIST}" 2>/dev/null || echo "unknown")"
rm -f "${IPA_INFO_PLIST}"

echo ""
echo "✅  Variant '${CONFIGURATION}' packaged successfully"
echo "    IPA  : $(basename "${IPA_FILE}") (${IPA_SIZE})"
echo "    Path : ${IPA_FILE}"

if [[ "${IPA_BUNDLE_ID}" == "${BUNDLE_ID}" ]]; then
  echo "    ID   : ${IPA_BUNDLE_ID} ✓"
else
  echo "    ⚠   Bundle ID mismatch!"
  echo "        expected : ${BUNDLE_ID}"
  echo "        actual   : ${IPA_BUNDLE_ID}"
  exit 1
fi
