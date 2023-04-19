#!/sbin/sh
#
# This file is part of The BiTGApps Project

# ADDOND_VERSION=3

if [ -z "$backuptool_ab" ]; then
  SYS="$S"
  TMP=/tmp
else
  SYS="/postinstall/system"
  TMP="/postinstall/tmp"
fi

# Required for SetupWizard
setup_config="false"

# Dedicated V3 Partitions
P="/product /system_ext /postinstall/product /postinstall/system_ext"

. /tmp/backuptool.functions

list_files() {
cat <<EOF
app/Calculator/Calculator.apk
app/Calendar/Calendar.apk
app/Contacts/Contacts.apk
app/DESKCLOCK/DESKCLOCK.apk
app/GoogleCalendarSyncAdapter/GoogleCalendarSyncAdapter.apk
app/GoogleContactsSyncAdapter/GoogleContactsSyncAdapter.apk
app/GoogleExtShared/GoogleExtShared.apk
app/KEYBOARD/KEYBOARD.apk
app/Markup/Markup.apk
app/Markup/lib/arm/libsketchology_native.so
app/Markup/lib/arm64/libsketchology_native.so
app/Photos/Photos.apk
app/Photos/lib/arm/libcronet.102.0.4973.2.so
app/Photos/lib/arm/libfilterframework_jni.so
app/Photos/lib/arm/libflacJNI.so
app/Photos/lib/arm/libframesequence.so
app/Photos/lib/arm/libnative_crash_handler_jni.so
app/Photos/lib/arm/libnative.so
app/Photos/lib/arm/liboliveoil.so
app/Photos/lib/arm/libwebp_android.so
priv-app/ConfigUpdater/ConfigUpdater.apk
priv-app/Dialer/Dialer.apk
priv-app/Gearhead/Gearhead.apk
priv-app/GmsCoreSetupPrebuilt/GmsCoreSetupPrebuilt.apk
priv-app/GoogleExtServices/GoogleExtServices.apk
priv-app/GoogleLoginService/GoogleLoginService.apk
priv-app/GoogleServicesFramework/GoogleServicesFramework.apk
priv-app/Messaging/Messaging.apk
priv-app/Services/Services.apk
priv-app/Phonesky/Phonesky.apk
priv-app/PrebuiltGmsCore/PrebuiltGmsCore.apk
priv-app/GoogleBackupTransport/GoogleBackupTransport.apk
priv-app/GoogleRestore/GoogleRestore.apk
priv-app/SetupWizardPrebuilt/SetupWizardPrebuilt.apk
priv-app/Wellbeing/Wellbeing.apk
etc/default-permissions/default-permissions.xml
etc/default-permissions/bitgapps-permissions.xml
etc/default-permissions/bitgapps-permissions-q.xml
etc/permissions/android.ext.services.xml
etc/permissions/com.google.android.dialer.support.xml
etc/permissions/com.google.android.maps.xml
etc/permissions/privapp-permissions-google.xml
etc/permissions/split-permissions-google.xml
etc/permissions/variants-permissions-google.xml
etc/preferred-apps/google.xml
etc/sysconfig/google.xml
etc/sysconfig/google_build.xml
etc/sysconfig/google_exclusives_enable.xml
etc/sysconfig/google-hiddenapi-package-whitelist.xml
etc/sysconfig/google-install-constraints-allowlist.xml
etc/sysconfig/google-rollback-package-whitelist.xml
etc/sysconfig/google-staged-installer-whitelist.xml
etc/security/fsverity/gms_fsverity_cert.der
etc/security/fsverity/play_store_fsi_cert.der
framework/com.google.android.dialer.support.jar
framework/com.google.android.maps.jar
product/overlay/PlayStoreOverlay.apk
EOF
}

case "$1" in
  backup)
    list_files | while read FILE DUMMY; do
      backup_file $S/"$FILE"
    done
  ;;
  restore)
    for f in $SYS $SYS/product $SYS/system_ext $P; do
      find $f -type d -name '*Calculator*' -exec rm -rf {} +
      find $f -type d -name 'Calendar' -exec rm -rf {} +
      find $f -type d -name 'Etar' -exec rm -rf {} +
      find $f -type d -name 'Contacts' -exec rm -rf {} +
      find $f -type d -name '*CLOCK*' -exec rm -rf {} +
      find $f -type d -name '*LATINIME*' -exec rm -rf {} +
      find $f -type d -name '*GALLERY*' -exec rm -rf {} +
      find $f -type d -name '*Dialer*' -exec rm -rf {} +
      find $f -type d -name '*messaging*' -exec rm -rf {} +
    done
    if [ "$setup_config" = "true" ]; then
      for f in $SYS $SYS/product $SYS/system_ext $P; do
        find $f -type d -name '*Provision*' -exec rm -rf {} +
        find $f -type d -name '*SetupWizard*' -exec rm -rf {} +
      done
    fi
    list_files | while read FILE REPLACEMENT; do
      R=""
      [ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
      [ -f "$C/$S/$FILE" ] && restore_file $S/"$FILE" "$R"
    done
    rm -rf $SYS/app/ExtShared $SYS/priv-app/ExtServices
    for i in $(list_files); do
      chown root:root "$SYS/$i" 2>/dev/null
      chmod 644 "$SYS/$i" 2>/dev/null
      chmod 755 "$(dirname "$SYS/$i")" 2>/dev/null
    done
  ;;
esac
