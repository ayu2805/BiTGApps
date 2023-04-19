#!/bin/bash
#
# This file is part of The BiTGApps Project

# Installer Tools
BUSYBOX="tools/busybox/busybox-arm"
ZIPSIGNER="tools/zipsigner/zipsigner.jar"

# Initialize Platform Sources
cp -rf sources/addon-sources/$1/Dialer $1/Dialer
cp -rf sources/addon-sources/$1/Gearhead $1/Gearhead
cp -rf sources/addon-sources/$1/Gmail $1/Gmail
cp -rf sources/addon-sources/$1/Keyboard $1/Keyboard
cp -rf sources/addon-sources/$1/Maps $1/Maps
cp -rf sources/addon-sources/$1/Markup $1/Markup
cp -rf sources/addon-sources/$1/Messaging $1/Messaging
cp -rf sources/addon-sources/$1/Photos $1/Photos
cp -rf sources/addon-sources/$1/Speech $1/Speech
cp -rf sources/addon-sources/$1/Velvet $1/Velvet

# Define Current Version
sed -i -e "s/@VERSION@/version="$VERSION"/g" $1/*/util_functions.sh

# Build Dialer Package
cp -f $BUSYBOX $1/Dialer
cd $1/Dialer
. envsetup.sh && rm -rf envsetup.sh
zip -qr9 Dialer-$RELEASE.zip * && cd ../..
cp -f $1/Dialer/Dialer-$RELEASE.zip build
# Sign Dialer Package
java -jar $ZIPSIGNER build/Dialer-$RELEASE.zip out/Dialer-$RELEASE-$2.zip

# Build Gearhead Package
cp -f $BUSYBOX $1/Gearhead
cd $1/Gearhead
. envsetup.sh && rm -rf envsetup.sh
zip -qr9 Gearhead-$RELEASE.zip * && cd ../..
cp -f $1/Gearhead/Gearhead-$RELEASE.zip build
# Sign Gearhead Package
java -jar $ZIPSIGNER build/Gearhead-$RELEASE.zip out/AndroidAuto-$RELEASE-$2.zip

# Build Gmail Package
cp -f $BUSYBOX $1/Gmail
cd $1/Gmail
. envsetup.sh && rm -rf envsetup.sh
zip -qr9 Gmail-$RELEASE.zip * && cd ../..
cp -f $1/Gmail/Gmail-$RELEASE.zip build
# Sign Gmail Package
java -jar $ZIPSIGNER build/Gmail-$RELEASE.zip out/Gmail-$RELEASE-$2.zip

# Build Keyboard Package
cp -f $BUSYBOX $1/Keyboard
cd $1/Keyboard
. envsetup.sh && rm -rf envsetup.sh
zip -qr9 Keyboard-$RELEASE.zip * && cd ../..
cp -f $1/Keyboard/Keyboard-$RELEASE.zip build
# Sign Keyboard Package
java -jar $ZIPSIGNER build/Keyboard-$RELEASE.zip out/LatinIME-$RELEASE-$2.zip

# Build Maps Package
cp -f $BUSYBOX $1/Maps
cd $1/Maps
. envsetup.sh && rm -rf envsetup.sh
zip -qr9 Maps-$RELEASE.zip * && cd ../..
cp -f $1/Maps/Maps-$RELEASE.zip build
# Sign Maps Package
java -jar $ZIPSIGNER build/Maps-$RELEASE.zip out/Maps-$RELEASE-$2.zip

# Build Markup Package
cp -f $BUSYBOX $1/Markup
cd $1/Markup
. envsetup.sh && rm -rf envsetup.sh
zip -qr9 Markup-$RELEASE.zip * && cd ../..
cp -f $1/Markup/Markup-$RELEASE.zip build
# Sign Markup Package
java -jar $ZIPSIGNER build/Markup-$RELEASE.zip out/Markup-$RELEASE-$2.zip

# Build Messaging Package
cp -f $BUSYBOX $1/Messaging
cd $1/Messaging
. envsetup.sh && rm -rf envsetup.sh
zip -qr9 Messaging-$RELEASE.zip * && cd ../..
cp -f $1/Messaging/Messaging-$RELEASE.zip build
# Sign Messaging Package
java -jar $ZIPSIGNER build/Messaging-$RELEASE.zip out/Messaging-$RELEASE-$2.zip

# Build Photos Package
cp -f $BUSYBOX $1/Photos
cd $1/Photos
. envsetup.sh && rm -rf envsetup.sh
zip -qr9 Photos-$RELEASE.zip * && cd ../..
cp -f $1/Photos/Photos-$RELEASE.zip build
# Sign Photos Package
java -jar $ZIPSIGNER build/Photos-$RELEASE.zip out/Photos-$RELEASE-$2.zip

# Build Speech Package
cp -f $BUSYBOX $1/Speech
cd $1/Speech
. envsetup.sh && rm -rf envsetup.sh
zip -qr9 Speech-$RELEASE.zip * && cd ../..
cp -f $1/Speech/Speech-$RELEASE.zip build
# Sign Speech Package
java -jar $ZIPSIGNER build/Speech-$RELEASE.zip out/GoogleTTS-$RELEASE-$2.zip

# Build Velvet Package
cp -f $BUSYBOX $1/Velvet
cd $1/Velvet
. envsetup.sh && rm -rf envsetup.sh
zip -qr9 Velvet-$RELEASE.zip * && cd ../..
cp -f $1/Velvet/Velvet-$RELEASE.zip build
# Sign Velvet Package
java -jar $ZIPSIGNER build/Velvet-$RELEASE.zip out/Assistant-$RELEASE-$2.zip

# Release Signed Builds
github-release upload \
  --owner "BiTGApps" \
  --repo "Addon-Release" \
  --token "$TOKEN" \
  --tag "${RELEASE}" \
  --release-name "BiTGApps ${RELEASE}" \
  "out/AndroidAuto-$RELEASE-$2.zip" \
  "out/Assistant-$RELEASE-$2.zip" \
  "out/Dialer-$RELEASE-$2.zip" \
  "out/Gmail-$RELEASE-$2.zip" \
  "out/GoogleTTS-$RELEASE-$2.zip" \
  "out/LatinIME-$RELEASE-$2.zip" \
  "out/Maps-$RELEASE-$2.zip" \
  "out/Markup-$RELEASE-$2.zip" \
  "out/Messaging-$RELEASE-$2.zip" \
  "out/Photos-$RELEASE-$2.zip"
