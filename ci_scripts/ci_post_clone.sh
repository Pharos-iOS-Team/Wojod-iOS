#!/bin/bash
# Xcode Cloud: runs after repo clone, before build.
# Swaps variant Common/ assets into Images.xcassets/Common/
# based on the active CI_BUILD_CONFIGURATION.

set -eo pipefail

REPO="${CI_PRIMARY_REPOSITORY_PATH:-/Volumes/workspace/repository}"
# CI_BUILD_CONFIGURATION is not always set during post-clone on Xcode Cloud.
# Default to Release so the script doesn't fail on unbound variable (-u).
CONFIG="${CI_BUILD_CONFIGURATION:-Release}"

# Install SwiftGen (not preinstalled on Xcode Cloud)
# Required by the SwiftGen build phase — without it, the build phase
# prints "error: SwiftGen not installed" which Xcode treats as a build error.
if ! which swiftgen > /dev/null 2>&1; then
    echo "→ Installing SwiftGen..."
    brew install swiftgen
    echo "✅ SwiftGen installed"
else
    echo "✅ SwiftGen already available"
fi

VARIANT_COMMON="${REPO}/App/Resources/Assets/${CONFIG}.xcassets/Common"
TARGET_COMMON="${REPO}/App/Resources/Images.xcassets/Common"

echo "→ ci_post_clone: CONFIG=${CONFIG}"

if [[ -d "${VARIANT_COMMON}" ]]; then
    rm -rf "${TARGET_COMMON}"
    mkdir -p "${TARGET_COMMON}"
    cp -R "${VARIANT_COMMON}/"* "${TARGET_COMMON}/"
    echo "✅ Swapped Common assets for ${CONFIG}"
else
    echo "⚠ No variant assets found at ${VARIANT_COMMON}, using base Images.xcassets/Common"
fi

# ─── Install Ruby gems (Fastlane) ─────────────
# Install into repo-local vendor/bundle to avoid sudo on Xcode Cloud.
# BUNDLE_PATH is exported so ci_post_xcodebuild.sh picks it up too.
export BUNDLE_PATH="${REPO}/vendor/bundle"
echo "→ Running bundle install (path: ${BUNDLE_PATH})..."
bundle install --gemfile="${REPO}/Gemfile" --quiet
echo "✅ Bundler gems ready"

# ─── Skip Plugin Validation ───────────────────
# We MUST use Apple's misspelled key "Validatation" for this to work
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES

# Include the correct spelling as a fallback for future Xcode versions
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidation -bool YES

# Skip macro fingerprint validation
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES