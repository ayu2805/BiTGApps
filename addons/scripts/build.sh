#!/bin/bash
#
# This file is part of The BiTGApps Project

# Installer Tools
BUSYBOX="tools/busybox/busybox-arm"
ZIPSIGNER="tools/zipsigner/zipsigner.jar"

# Initialize Common Sources
cp -rf sources/addon-sources/$1/Calculator $1/Calculator
cp -rf sources/addon-sources/$1/Calendar $1/Calendar
cp -rf sources/addon-sources/$1/Chrome $1/Chrome
cp -rf sources/addon-sources/$1/Contacts $1/Contacts
cp -rf sources/addon-sources/$1/DeskClock $1/DeskClock
cp -rf sources/addon-sources/$1/WebView $1/WebView
cp -rf sources/addon-sources/$1/Wellbeing $1/Wellbeing

# Define Current Version
sed -i -e "s/@VERSION@/version="$VERSION"/g" $1/*/util_functions.sh

# Build Calculator Package
cp -f $BUSYBOX $1/Calculator
cd $1/Calculator
. envsetup.sh && rm -rf envsetup.sh
zip -qr9 Calculator-$RELEASE.zip * && cd ../..
cp -f $1/Calculator/Calculator-$RELEASE.zip build
# Sign Calculator Package
java -jar $ZIPSIGNER build/Calculator-$RELEASE.zip out/Calculator-$RELEASE.zip

# Build Calendar Package
cp -f $BUSYBOX $1/Calendar
cd $1/Calendar
. envsetup.sh && rm -rf envsetup.sh
zip -qr9 Calendar-$RELEASE.zip * && cd ../..
cp -f $1/Calendar/Calendar-$RELEASE.zip build
# Sign Calendar Package
java -jar $ZIPSIGNER build/Calendar-$RELEASE.zip out/Calendar-$RELEASE.zip

# Build Chrome Package
cp -f $BUSYBOX $1/Chrome
cd $1/Chrome
. envsetup.sh && rm -rf envsetup.sh
zip -qr9 Chrome-$RELEASE.zip * && cd ../..
cp -f $1/Chrome/Chrome-$RELEASE.zip build
# Sign Chrome Package
java -jar $ZIPSIGNER build/Chrome-$RELEASE.zip out/Chrome-$RELEASE.zip

# Build Contacts Package
cp -f $BUSYBOX $1/Contacts
cd $1/Contacts
. envsetup.sh && rm -rf envsetup.sh
zip -qr9 Contacts-$RELEASE.zip * && cd ../..
cp -f $1/Contacts/Contacts-$RELEASE.zip build
# Sign Contacts Package
java -jar $ZIPSIGNER build/Contacts-$RELEASE.zip out/Contacts-$RELEASE.zip

# Build DeskClock Package
cp -f $BUSYBOX $1/DeskClock
cd $1/DeskClock
. envsetup.sh && rm -rf envsetup.sh
zip -qr9 DeskClock-$RELEASE.zip * && cd ../..
cp -f $1/DeskClock/DeskClock-$RELEASE.zip build
# Sign DeskClock Package
java -jar $ZIPSIGNER build/DeskClock-$RELEASE.zip out/DeskClock-$RELEASE.zip

# Build WebView Package
cp -f $BUSYBOX $1/WebView
cd $1/WebView
. envsetup.sh && rm -rf envsetup.sh
zip -qr9 WebView-$RELEASE.zip * && cd ../..
cp -f $1/WebView/WebView-$RELEASE.zip build
# Sign WebView Package
java -jar $ZIPSIGNER build/WebView-$RELEASE.zip out/WebView-$RELEASE.zip

# Build Wellbeing Package
cp -f $BUSYBOX $1/Wellbeing
cd $1/Wellbeing
. envsetup.sh && rm -rf envsetup.sh
zip -qr9 Wellbeing-$RELEASE.zip * && cd ../..
cp -f $1/Wellbeing/Wellbeing-$RELEASE.zip build
# Sign Wellbeing Package
java -jar $ZIPSIGNER build/Wellbeing-$RELEASE.zip out/Wellbeing-$RELEASE.zip

# Release Signed Builds
github-release upload \
  --owner "BiTGApps" \
  --repo "Addon-Release" \
  --token "$TOKEN" \
  --tag "${RELEASE}" \
  --release-name "BiTGApps ${RELEASE}" \
  "out/Calculator-$RELEASE.zip" \
  "out/Calendar-$RELEASE.zip" \
  "out/Chrome-$RELEASE.zip" \
  "out/Contacts-$RELEASE.zip" \
  "out/DeskClock-$RELEASE.zip" \
  "out/WebView-$RELEASE.zip" \
  "out/Wellbeing-$RELEASE.zip"
