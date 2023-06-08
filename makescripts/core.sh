#!/bin/bash
#
# This file is part of The BiTGApps Project

# Runtime Variables
ARCH="$1"
API="$2"

# Build Defaults
BUILDDIR="build"
OUTDIR="out"
TYPE="GApps"

# Common Sources
ALLSOURCES="sources/common-sources"

# Google Apps Sources
SOURCES="sources/$ARCH-sources/$API"

# Installer Backend
UPDATEBINARY="scripts/update-binary.sh"
UPDATERSCRIPT="scripts/updater-script.sh"
INSTALLER="scripts/installer.sh"
OTASCRIPT="scripts/70-bitgapps.sh"
UTILITYSCRIPT="scripts/util_functions.sh"

# Installer Tools
BUSYBOX="tools/busybox/busybox-arm"
ZIPSIGNER="tools/zipsigner/zipsigner.jar"

# Internal Structure
METADIR="META-INF/com/google/android"
ZIP="zip"
CORE="$ZIP/core"
SYS="$ZIP/sys"
FRAMEWORK="$ZIP/framework"
OVERLAY="$ZIP/overlay"
OUT="$ZIP/out"

license() {
echo "This BiTGApps build is provided ONLY as courtesy by The BiTGApps Project and is without warranty of ANY kind.

This build is authored by TheHitMan7 and is as such protected by The BiTGApps Project's copyright.
This build is provided under the terms that it can be freely used for personal use only and is not allowed to be mirrored to the public other than author.
You are not allowed to modify this build for further (re)distribution.

The APKs found in this build are developed and owned by Google Inc.
They are included only for your convenience, neither TheHitMan7 and The BiTGApps Project have no ownership over them.
The user self is responsible for obtaining the proper licenses for the APKs, e.g. via Google's Play Store.
To use Google's applications you accept to Google's license agreement and further distribution of Google's application
are subject of Google's terms and conditions, these can be found at http://www.google.com/policies/

BusyBox is subject to the GPLv2, its license can be found at https://www.busybox.net/license.html

Any other intellectual property of this build, like e.g. the file and folder structure and the installation scripts are part of The BiTGApps Project and are subject
to the GPLv3. The applicable license can be found at https://www.gnu.org/licenses/gpl-3.0.txt" >"$BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/LICENSE"
}

default() {
  cp -f $SOURCES/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
  cp -f $SOURCES/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
  cp -f $SOURCES/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
  cp -f $SOURCES/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
  cp -f $SOURCES/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
  cp -f $SOURCES/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
  cp -f $SOURCES/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
  cp -f $SOURCES/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
  cp -f $SOURCES/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
}

legacy() {
  case $API in
    24 | 25 )
      cp -f $SOURCES/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCES/priv-app/GoogleLoginService.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
      ;;
    26 | 27 )
      cp -f $SOURCES/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
      ;;
  esac
}

wizard() {
  case $API in
    24 | 25 | 26 | 27 )
      cp -f $SOURCES/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
      ;;
    28 )
      cp -f $SOURCES/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCES/priv-app/GoogleRestore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
      ;;
    29 | 30 | 31 | 32 | 33 )
      cp -f $SOURCES/priv-app/GoogleRestore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
      ;;
  esac
}

common() {
  cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
  cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
  cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
  cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
  cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
  cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
  cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
  cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
  cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
}

overlay() {
  if [ "$API" -ge "30" ]; then
    cp -f $ALLSOURCES/overlay/PlayStoreOverlay.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
  fi
}

backend() {
  cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
  cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
  cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
  cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
  cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
  cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
}

# replace_line <file> <line replace string> <replacement line>
replace_line() {
  if grep -q "$2" $1; then
    local line=$(grep -n "$2" $1 | head -n1 | cut -d: -f1)
    sed -i "${line}s;.*;${3};" $1
  fi
}

checker() {
  OUT="$BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP"
  cd $OUT
  for tar in $(find $1 $2 -type f -iname '*'); do
    tar -xf $tar -C out | cut -d/ -f2-
  done
  CAPACITY="$(du -sxk out | awk '{ print $1 }')"
  # This include 10MB's of Buffer Space
  CAPACITY="$(($CAPACITY+10000))"
  rm -rf out && cd ../../../../..
}

case $API in
  24) ANDROID="7.1.1"; supported_sdk='"25"'; supported_version='"7.1.1"' ;;
  25) ANDROID="7.1.2"; supported_sdk='"25"'; supported_version='"7.1.2"' ;;
  26) ANDROID="8.0.0"; supported_sdk='"26"'; supported_version='"8.0.0"' ;;
  27) ANDROID="8.1.0"; supported_sdk='"27"'; supported_version='"8.1.0"' ;;
  28) ANDROID="9.0.0"; supported_sdk='"28"'; supported_version='"9"' ;;
  29) ANDROID="10.0.0"; supported_sdk='"29"'; supported_version='"10"' ;;
  30) ANDROID="11.0.0"; supported_sdk='"30"'; supported_version='"11"' ;;
  31) ANDROID="12.0.0"; supported_sdk='"31"'; supported_version='"12"' ;;
  32) ANDROID="12.1.0"; supported_sdk='"32"'; supported_version='"12"' ;;
  33) ANDROID="13.0.0"; supported_sdk='"33"'; supported_version='"13"' ;;
esac

case $ARCH in
  arm) supported_architecture='"armeabi-v7a"' ;;
  arm64) supported_architecture='"arm64-v8a"' ;;
esac

# Create Build Directory
test -d $BUILDDIR || mkdir $BUILDDIR
test -d $BUILDDIR/$TYPE || mkdir $BUILDDIR/$TYPE
test -d $BUILDDIR/$TYPE/$ARCH || mkdir $BUILDDIR/$TYPE/$ARCH
# Create OUT Directory
test -d $OUTDIR || mkdir $OUTDIR
test -d $OUTDIR/$TYPE || mkdir $OUTDIR/$TYPE
test -d $OUTDIR/$TYPE/$ARCH || mkdir $OUTDIR/$TYPE/$ARCH
echo "Generating BiTGApps package for $ARCH with API level $API"
# Create Release Directory
mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-${ANDROID}-${RELEASE}"
RELEASEDIR="BiTGApps-${ARCH}-${ANDROID}-${RELEASE}"
# Create Package Components
mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
if [ "$API" -ge "30" ]; then
  mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
fi
mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OUT
# Install Package Components
default; legacy; wizard; common; overlay; backend; license; checker core sys
# Current Package Variables
replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/installer.sh supported_sdk="" supported_sdk="$supported_sdk"
replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/installer.sh supported_version="" supported_version="$supported_version"
replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/installer.sh supported_architecture="" supported_architecture="$supported_architecture"
# Create Utility Script
replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
# Reflect Installation Size
sed -i -e "s|@CAPACITY@|$CAPACITY|g" $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh
# Create BiTGApps Package
cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
zip -qr9 ${RELEASEDIR}.zip *
cd ../../../..
mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
# Sign BiTGApps Package
java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-${VARIANT}.zip 2>/dev/null
# List Signed Package
rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-${VARIANT}.zip
