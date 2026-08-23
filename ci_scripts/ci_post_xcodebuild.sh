#!/bin/bash
# Xcode Cloud: runs after every xcodebuild step.
#
# Routing:
#   • archive action, NON-Debug workflow → export IPA → submit to App Store (Waiting for Review)
#   • archive action, Debug workflow     → post Jira comment on ticket found in branch name
#   • any other action                  → no-op
#
# Required Xcode Cloud environment variables (App Store Connect → workflow → Edit → Environment):
#
#   AuthKey_SMKJPP93WY.p8 is already committed to the repo — no key env var needed.
#   KEY_ID, ISSUER_ID, and KEY_FILE_PATH are set directly below in the script.
#
#   Debug - Wojod workflow only:
#     JIRA_USERNAME   your-email@company.com
#     JIRA_PASSWORD   your-jira-api-token   (mark secret)
#     jira_url        https://yourcompany.atlassian.net
#
# Change the string "Debug - Wojod" below if your workflow name differs.

set -eo pipefail

REPO="${CI_PRIMARY_REPOSITORY_PATH}"

# Xcode Cloud runs scripts from ci_scripts/; Fastlane needs to be invoked from repo root.
cd "${REPO}"

# Gems were installed here by ci_post_clone.sh (avoids sudo on system paths).
export BUNDLE_PATH="${REPO}/vendor/bundle"

echo "→ ci_post_xcodebuild | workflow=${CI_WORKFLOW} | action=${CI_XCODEBUILD_ACTION} | branch=${CI_BRANCH:-<no branch>}"

# ── Only act on archive ────────────────────────────────────────────────────────
if [[ "${CI_XCODEBUILD_ACTION}" != "archive" ]]; then
    echo "→ Nothing to do for action '${CI_XCODEBUILD_ACTION}', exiting."
    exit 0
fi

# ── Debug: post Jira comment ───────────────────────────────────────────────────
if [[ "${CI_WORKFLOW}" == "Debug - Wojod" ]]; then
    echo "→ Debug workflow — posting Jira comment for branch: ${CI_BRANCH}..."
    bundle exec fastlane ci_jira_comment
    echo "✅ Jira comment step done."
    exit 0
fi

# ── All other schemas: submit to App Store (Waiting for Review) ───────────────
# The .p8 key is committed to the repo — no Xcode Cloud env var needed for it.
export KEY_ID="SMKJPP93WY"
export ISSUER_ID="15edc47d-4fe3-4c73-b116-142c1035e1f2"
export KEY_FILE_PATH="${REPO}/fastlane/AuthKey_SMKJPP93WY.p8"

echo "→ Submitting to App Store for workflow '${CI_WORKFLOW}'..."
bundle exec fastlane ci_submit_to_app_store
echo "✅ App Store submission done."
