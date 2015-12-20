#!/bin/sh
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. No deployment will be done."
  exit 0
fi
if [[ "$TRAVIS_BRANCH" != "master" ]]; then
  echo "Testing on a branch other than master. No deployment will be done."
  exit 0
fi

PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_NAME.mobileprovision"
OUTPUTDIR="$PWD/build/Release-iphoneos"

xcrun -log -sdk iphoneos PackageApplication "$OUTPUTDIR/$APP_NAME.app" -o "$OUTPUTDIR/$APP_NAME.ipa" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"


if [ ! -z "$HOCKEY_APP_ID" ] && [ ! -z "$HOCKEY_APP_TOKEN" ]; then
  echo ""
  echo "***************************"
  echo "* Uploading to pgyer  *"
  echo "***************************"
  curl http://www.pgyer.com/apiv1/app/upload \
    -F uKey="$PGYER_APP_KEY" \
    -F _api_key="$PGYER_API_KEY" \
    -F file="@$OUTPUTDIR/$APP_NAME.ipa" \
fi
