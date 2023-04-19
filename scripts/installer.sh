# This file is part of The BiTGApps Project

# List of GApps Packages
BITGAPPS="
zip/core/ConfigUpdater.tar.xz
zip/core/GmsCoreSetupPrebuilt.tar.xz
zip/core/GoogleExtServices.tar.xz
zip/core/GoogleLoginService.tar.xz
zip/core/GoogleServicesFramework.tar.xz
zip/core/Phonesky.tar.xz
zip/core/PrebuiltGmsCore.tar.xz
zip/sys/GoogleCalendarSyncAdapter.tar.xz
zip/sys/GoogleContactsSyncAdapter.tar.xz
zip/sys/GoogleExtShared.tar.xz
zip/Sysconfig.tar.xz
zip/Default.tar.xz
zip/Permissions.tar.xz
zip/Preferred.tar.xz
zip/overlay/PlayStoreOverlay.tar.xz"

# List of Extra Configs
FRAMEWORK="
zip/framework/DialerPermissions.tar.xz
zip/framework/DialerFramework.tar.xz
zip/framework/MapsPermissions.tar.xz
zip/framework/MapsFramework.tar.xz"

# List of SetupWizard Packages
SETUPWIZARD="
zip/core/GoogleBackupTransport.tar.xz
zip/core/GoogleRestore.tar.xz
zip/core/SetupWizardPrebuilt.tar.xz"

# Magisk Current Base Folder
MIRROR="$(magisk --path)/.magisk/mirror"

# Wait for Mounted Partitions
getprop() { /sbin/getprop $1; }
rm() { /sbin/rm $1 $2; }

# Workaround for Findutils
rm="/sbin/rm"

# Wait for Mounted Partitions
if [ -f "/system/bin/getprop" ]; then
  getprop() { /system/bin/getprop $1; }
fi
if [ -f "/system/bin/rm" ]; then
  rm() { /system/bin/rm $1 $2; }
fi

# Workaround for Findutils
rm="/system/bin/rm"

# Installation base is Bootmode script
if [[ "$(getprop "sys.bootmode")" = "1" ]]; then
  # System is writable
  if ! touch $SYSTEM/.rw >/dev/null 2>&1; then
    echo "! Read-only file system"
    exit 1
  fi
fi

# Allow mounting, when installation base is Magisk
if [[ "$(getprop "sys.bootmode")" = "2" ]]; then
  # Mount actual partitions
  mount -o remount,rw,errors=continue / > /dev/null 2>&1
  mount -o remount,rw,errors=continue /dev/root > /dev/null 2>&1
  mount -o remount,rw,errors=continue /dev/block/dm-0 > /dev/null 2>&1
  mount -o remount,rw,errors=continue /system > /dev/null 2>&1
  mount -o remount,rw,errors=continue /product > /dev/null 2>&1
  mount -o remount,rw,errors=continue /system_ext > /dev/null 2>&1
  # Mount mirror partitions
  mount -o remount,rw,errors=continue $MIRROR/system_root 2>/dev/null
  mount -o remount,rw,errors=continue $MIRROR/system 2>/dev/null
  mount -o remount,rw,errors=continue $MIRROR/product 2>/dev/null
  mount -o remount,rw,errors=continue $MIRROR/system_ext 2>/dev/null
  # Product is a dedicated partition
  PRODUCT="$(grep -s " $(readlink -f /product) " /proc/mounts)"
  # Set installation layout
  SYSTEM="$MIRROR/system"
  # System is writable
  if ! touch $SYSTEM/.rw >/dev/null 2>&1; then
    echo "! Read-only file system"
    exit 1
  fi
  # Product is a dedicated partition
  [[ "$PRODUCT" ]] && ln -sf /product /system
  # Dedicated V3 Partitions
  P="/product /system_ext"
fi

# Detect whether in boot mode
[ -z $BOOTMODE ] && ps | grep zygote | grep -qv grep && BOOTMODE="true"
[ -z $BOOTMODE ] && ps -A 2>/dev/null | grep zygote | grep -qv grep && BOOTMODE="true"
[ -z $BOOTMODE ] && BOOTMODE="false"

# Strip leading directories
if [ "$BOOTMODE" = "false" ]; then
  DEST="-f4-"
else
  DEST="-f5-"
fi

# Extract utility script
if [ "$BOOTMODE" = "false" ]; then
  unzip -oq "$ZIPFILE" "util_functions.sh" -d "$TMP"
fi
# Allow unpack, when installation base is Magisk
if [[ "$(getprop "sys.bootmode")" = "2" ]]; then
  $(unzip -oq "$ZIPFILE" "util_functions.sh" -d "$TMP")
fi
chmod +x "$TMP/util_functions.sh"

# Load utility functions
. $TMP/util_functions.sh

# Helper Functions
ui_print() {
  if [ "$BOOTMODE" = "true" ]; then
    echo "$1"
  fi
  if [ "$BOOTMODE" = "false" ]; then
    echo -n -e "ui_print $1\n" >> /proc/self/fd/$OUTFD
    echo -n -e "ui_print\n" >> /proc/self/fd/$OUTFD
  fi
}

is_mounted() {
  grep -q " $(readlink -f $1) " /proc/mounts 2>/dev/null
  return $?
}

grep_cmdline() {
  local REGEX="s/^$1=//p"
  { echo $(cat /proc/cmdline)$(sed -e 's/[^"]//g' -e 's/""//g' /proc/cmdline) | xargs -n 1; \
    sed -e 's/ = /=/g' -e 's/, /,/g' -e 's/"//g' /proc/bootconfig; \
  } 2>/dev/null | sed -n "$REGEX"
}

setup_mountpoint() {
  test -L $1 && mv -f $1 ${1}_link
  if [ ! -d $1 ]; then
    rm -f $1
    mkdir $1
  fi
}

mount_apex() {
  if "$BOOTMODE"; then
    return 255
  fi
  test -d "$SYSTEM/apex" || return 255
  ui_print "- Mounting /apex"
  local apex dest loop minorx num
  setup_mountpoint /apex
  test -e /dev/block/loop1 && minorx=$(ls -l /dev/block/loop1 | awk '{ print $6 }') || minorx="1"
  num="0"
  for apex in $SYSTEM/apex/*; do
    dest=/apex/$(basename $apex | sed -E -e 's;\.apex$|\.capex$;;')
    test "$dest" = /apex/com.android.runtime.release && dest=/apex/com.android.runtime
    mkdir -p $dest
    case $apex in
      *.apex|*.capex)
        # Handle CAPEX APKs
        unzip -oq $apex original_apex -d /apex
        if [ -f "/apex/original_apex" ]; then
          apex="/apex/original_apex"
        fi
        # Handle APEX APKs
        unzip -oq $apex apex_payload.img -d /apex
        mv -f /apex/apex_payload.img $dest.img
        mount -t ext4 -o ro,noatime $dest.img $dest 2>/dev/null
        if [ $? != 0 ]; then
          while [ $num -lt 64 ]; do
            loop=/dev/block/loop$num
            (mknod $loop b 7 $((num * minorx))
            losetup $loop $dest.img) 2>/dev/null
            num=$((num + 1))
            losetup $loop | grep -q $dest.img && break
          done
          mount -t ext4 -o ro,loop,noatime $loop $dest 2>/dev/null
          if [ $? != 0 ]; then
            losetup -d $loop 2>/dev/null
          fi
        fi
      ;;
      *) mount -o bind $apex $dest;;
    esac
  done
  export ANDROID_RUNTIME_ROOT="/apex/com.android.runtime"
  export ANDROID_TZDATA_ROOT="/apex/com.android.tzdata"
  export ANDROID_ART_ROOT="/apex/com.android.art"
  export ANDROID_I18N_ROOT="/apex/com.android.i18n"
  local APEXJARS=$(find /apex -name '*.jar' | sort | tr '\n' ':')
  local FWK=$SYSTEM/framework
  export BOOTCLASSPATH="${APEXJARS}\
  $FWK/framework.jar:\
  $FWK/framework-graphics.jar:\
  $FWK/ext.jar:\
  $FWK/telephony-common.jar:\
  $FWK/voip-common.jar:\
  $FWK/ims-common.jar:\
  $FWK/framework-atb-backward-compatibility.jar:\
  $FWK/android.test.base.jar"
}

umount_apex() {
  if "$BOOTMODE"; then
    return 255
  fi
  test -d /apex || return 255
  local dest loop
  for dest in $(find /apex -type d -mindepth 1 -maxdepth 1); do
    if [ -f $dest.img ]; then
      loop=$(mount | grep $dest | cut -d" " -f1)
    fi
    (umount -l $dest
    losetup -d $loop) 2>/dev/null
  done
  rm -rf /apex 2>/dev/null
  unset ANDROID_RUNTIME_ROOT
  unset ANDROID_TZDATA_ROOT
  unset ANDROID_ART_ROOT
  unset ANDROID_I18N_ROOT
  unset BOOTCLASSPATH
}

umount_all() {
  if [ "$BOOTMODE" = "false" ]; then
    umount -l /system > /dev/null 2>&1
    umount -l /system_root > /dev/null 2>&1
    umount -l /product > /dev/null 2>&1
    umount -l /system_ext > /dev/null 2>&1
  fi
}

mount_all() {
  if "$BOOTMODE"; then
    return 255
  fi
  # Check A/B Partition Slot
  [ "$slot" ] || slot=$(getprop ro.boot.slot_suffix)
  [ "$slot" ] || slot=$(grep_cmdline androidboot.slot_suffix)
  [ "$slot" ] || slot=$(grep_cmdline androidboot.slot)
  # Store and reset environmental variables
  OLD_LD_LIB=$LD_LIBRARY_PATH && unset LD_LIBRARY_PATH
  OLD_LD_PRE=$LD_PRELOAD && unset LD_PRELOAD
  OLD_LD_CFG=$LD_CONFIG_FILE && unset LD_CONFIG_FILE
  # Make sure random won't get blocked
  mount -o bind /dev/urandom /dev/random
  if ! is_mounted /cache; then
    mount /cache > /dev/null 2>&1
  fi
  if ! is_mounted /data; then
    mount /data > /dev/null 2>&1
  fi
  mount -o ro -t auto /product > /dev/null 2>&1
  mount -o ro -t auto /system_ext > /dev/null 2>&1
  [ "$ANDROID_ROOT" ] || ANDROID_ROOT="/system"
  setup_mountpoint $ANDROID_ROOT
  if ! is_mounted $ANDROID_ROOT; then
    mount -o ro -t auto $ANDROID_ROOT > /dev/null 2>&1
  fi
  # Mount bind operation
  case $ANDROID_ROOT in
    /system_root) setup_mountpoint /system;;
    /system)
      if ! is_mounted /system && ! is_mounted /system_root; then
        setup_mountpoint /system_root
        mount -o ro -t auto /system_root
      elif [ -f "/system/system/build.prop" ]; then
        setup_mountpoint /system_root
        mount --move /system /system_root
        mount -o bind /system_root/system /system
      fi
      if [ $? != 0 ]; then
        umount -l /system > /dev/null 2>&1
      fi
    ;;
  esac
  case $ANDROID_ROOT in
    /system)
      if ! is_mounted $ANDROID_ROOT && [ -e /dev/block/mapper/system$slot ]; then
        mount -o ro -t auto /dev/block/mapper/system$slot /system_root > /dev/null 2>&1
        mount -o ro -t auto /dev/block/mapper/product$slot /product > /dev/null 2>&1
        mount -o ro -t auto /dev/block/mapper/system_ext$slot /system_ext > /dev/null 2>&1
      fi
      if ! is_mounted $ANDROID_ROOT && [ -e /dev/block/bootdevice/by-name/system$slot ]; then
        mount -o ro -t auto /dev/block/bootdevice/by-name/system$slot /system_root > /dev/null 2>&1
        mount -o ro -t auto /dev/block/bootdevice/by-name/product$slot /product > /dev/null 2>&1
        mount -o ro -t auto /dev/block/bootdevice/by-name/system_ext$slot /system_ext > /dev/null 2>&1
      fi
    ;;
  esac
  # Mount bind operation
  if is_mounted /system_root; then
    if [ -f "/system_root/build.prop" ]; then
      mount -o bind /system_root /system
    else
      mount -o bind /system_root/system /system
    fi
  fi
  for block in system product system_ext; do
    for slot in "" _a _b; do
      blockdev --setrw /dev/block/mapper/$block$slot > /dev/null 2>&1
    done
  done
  mount -o remount,rw -t auto / > /dev/null 2>&1
  ui_print "- Mounting /system"
  if [ "$(grep -wo '/system' /proc/mounts)" ]; then
    mount -o remount,rw -t auto /system > /dev/null 2>&1
    is_mounted /system || on_abort "! Cannot mount /system"
  fi
  if [ "$(grep -wo '/system_root' /proc/mounts)" ]; then
    mount -o remount,rw -t auto /system_root > /dev/null 2>&1
    is_mounted /system_root || on_abort "! Cannot mount /system_root"
  fi
  ui_print "- Mounting /product"
  mount -o remount,rw -t auto /product > /dev/null 2>&1
  ui_print "- Mounting /system_ext"
  mount -o remount,rw -t auto /system_ext > /dev/null 2>&1
  # Set installation layout
  SYSTEM="/system"
  # System is writable
  if ! touch $SYSTEM/.rw >/dev/null 2>&1; then
    on_abort "! Read-only file system"
  fi
  # Product is a dedicated partition
  if is_mounted /product; then
    ln -sf /product /system
  fi
  # Dedicated V3 Partitions
  P="/product /system_ext"
}

unmount_all() {
  if [ "$BOOTMODE" = "false" ]; then
    ui_print "- Unmounting partitions"
    umount -l /system > /dev/null 2>&1
    umount -l /system_root > /dev/null 2>&1
    umount -l /product > /dev/null 2>&1
    umount -l /system_ext > /dev/null 2>&1
    umount -l /dev/random > /dev/null 2>&1
    # Restore environmental variables
    export LD_LIBRARY_PATH=$OLD_LD_LIB
    export LD_PRELOAD=$OLD_LD_PRE
    export LD_CONFIG_FILE=$OLD_LD_CFG
  fi
}

f_cleanup() { (find .$TMP -mindepth 1 -maxdepth 1 -type f -not -name 'recovery.log' -not -name 'busybox-arm' -exec $rm -rf '{}' \;); }

d_cleanup() { (find .$TMP -mindepth 1 -maxdepth 1 -type d -exec $rm -rf '{}' \;); }

on_abort() {
  ui_print "$*"
  $BOOTMODE && exit 1
  umount_apex
  unmount_all
  f_cleanup 2>/dev/null
  d_cleanup 2>/dev/null
  ui_print "! Installation failed"
  ui_print " "
  true
  sync
  exit 1
}

on_installed() {
  umount_apex
  unmount_all
  f_cleanup 2>/dev/null
  d_cleanup 2>/dev/null
  ui_print "- Installation complete"
  ui_print " "
  true
  sync
  exit "$?"
}

get_file_prop() { grep -m1 "^$2=" "$1" | cut -d= -f2; }

get_prop() {
  for f in $PROPFILES; do
    if [ -e "$f" ]; then
      prop="$(get_file_prop "$f" "$1")"
      if [ -n "$prop" ]; then
        break
      fi
    fi
  done
  if [ -z "$prop" ]; then
    getprop "$1" | cut -c1-
  else
    printf "$prop"
  fi
}

extracted() {
  file_list="$(find "$UNZIP_DIR/" -mindepth 1 -type f | cut -d/ ${DEST})"
  dir_list="$(find "$UNZIP_DIR/" -mindepth 1 -type d | cut -d/ ${DEST})"
  for file in $file_list; do
    install -D "$UNZIP_DIR/${file}" "$SYSTEM/${file}"
    chmod 0644 "$SYSTEM/${file}"
    ch_con system "$SYSTEM/${file}"
    # Overlays require different SELinux context
    case $file in
      */overlay/*) ch_con vendor_overlay "$SYSTEM/${file}";;
    esac
  done
  for dir in $dir_list; do
    chmod 0755 "$SYSTEM/${dir}"
    ch_con system "$SYSTEM/${dir}"
  done
}

# Begin installation
print_title "BiTGApps $version Installer"

# Helper Functions
umount_all
mount_all
mount_apex

# Internal Calls
getprop() { /system/bin/getprop $1; }
rm() { /system/bin/rm $1 $2; }

# Workaround for Findutils
rm="/system/bin/rm"

# Sideload Optional Configuration
if [ "$BOOTMODE" = "false" ]; then
  unzip -oq "$ZIPFILE" "bitgapps-config.prop" -d "$TMP"
fi
# Allow unpack, when installation base is Magisk
if [[ "$(getprop "sys.bootmode")" = "2" ]]; then
  $(unzip -oq "$ZIPFILE" "bitgapps-config.prop" -d "$TMP")
fi

# Optional Configuration
for d in /sdcard /sdcard1 /external_sd /data/media/0 /tmp /dev/tmp; do
  for f in $(find $d -type f -iname "bitgapps-config.prop" 2>/dev/null); do
    if [ -f "$f" ]; then BITGAPPS_CONFIG="$f"; fi
  done
done

# Common Build Properties
PROPFILES="$SYSTEM/build.prop $BITGAPPS_CONFIG"

# Current Package Variables
android_sdk="$(get_prop "ro.build.version.sdk")"
supported_sdk=""
android_version="$(get_prop "ro.build.version.release")"
supported_version=""
device_architecture="$(get_prop "ro.product.cpu.abi")"
supported_architecture=""

# Check Android SDK
if [ "$android_sdk" = "$supported_sdk" ]; then
  ui_print "- Android SDK version: $android_sdk"
else
  on_abort "! Unsupported Android SDK version"
fi

# Check Android Version
if [ "$android_version" = "$supported_version" ]; then
  ui_print "- Android version: $android_version"
else
  on_abort "! Unsupported Android version"
fi

# Check Device Platform
if [ "$device_architecture" = "$supported_architecture" ]; then
  ui_print "- Android platform: $device_architecture"
else
  on_abort "! Unsupported Android platform"
fi

# Check SetupWizard Installation
supported_setup_config="false"
if [ -f "$BITGAPPS_CONFIG" ]; then
  supported_setup_config="$(get_prop "ro.config.setupwizard")"
  # Re-write missing configuration
  if [ -z "$supported_setup_config" ]; then
    supported_setup_config="false"
  fi
fi

# Exclude Reclaimed GApps Space
list_files | while read FILE CLAIMED; do
  PKG="$(find /system -type d -iname $FILE)"
  CLAIMED="$(du -sxk "$PKG" | cut -f1)"
  # Reclaimed GApps Space in KB's
  echo "$CLAIMED" >> $TMP/RAW
done
# Remove White Spaces
sed -i '/^[[:space:]]*$/d' $TMP/RAW
# Reclaimed Removal Space in KB's
if ! grep -soEq '[0-9]+' "$TMP/RAW"; then
  # When raw output of claimed is empty
  CLAIMED="0"
else
  CLAIMED="$(grep -soE '[0-9]+' "$TMP/RAW" | paste -sd+ | bc)"
fi

# Get the available space left on the device
size=`df -k /system | tail -n 1 | tr -s ' ' | cut -d' ' -f4`
# Disk space in human readable format (k=1024)
ds_hr=`df -h /system | tail -n 1 | tr -s ' ' | cut -d' ' -f4`

# Check Required Space
CAPACITY="$(($CAPACITY-$CLAIMED))"
if [ "$size" -gt "$CAPACITY" ]; then
  ui_print "- System Space: $ds_hr"
else
  ui_print "! Insufficient partition size"
  on_abort "! Current space: $ds_hr"
fi

# Delete Runtime Permissions
RTP="$(find /data -type f -iname "runtime-permissions.xml")"
if [ -e "$RTP" ]; then
  if ! grep -qwo 'com.android.vending' $RTP; then
    rm -rf "$RTP"
  fi
fi

# Compressed Packages
ZIP_FILE="$TMP/zip"
# Extracted Packages
mkdir $TMP/unzip
# Initial link
UNZIP_DIR="$TMP/unzip"
# Create links
TMP_SYS="$UNZIP_DIR/app"
TMP_PRIV="$UNZIP_DIR/priv-app"
TMP_FRAMEWORK="$UNZIP_DIR/framework"
TMP_SYSCONFIG="$UNZIP_DIR/etc/sysconfig"
TMP_DEFAULT="$UNZIP_DIR/etc/default-permissions"
TMP_PERMISSION="$UNZIP_DIR/etc/permissions"
TMP_PREFERRED="$UNZIP_DIR/etc/preferred-apps"
TMP_OVERLAY="$UNZIP_DIR/product/overlay"

# Create dir
for d in \
  $UNZIP_DIR/app \
  $UNZIP_DIR/priv-app \
  $UNZIP_DIR/framework \
  $UNZIP_DIR/etc/sysconfig \
  $UNZIP_DIR/etc/default-permissions \
  $UNZIP_DIR/etc/permissions \
  $UNZIP_DIR/etc/preferred-apps \
  $UNZIP_DIR/product/overlay; do
  install -d "$d"
  chmod -R 0755 $TMP
done

# Pathmap
SYSTEM_ADDOND="$SYSTEM/addon.d"
SYSTEM_APP="$SYSTEM/app"
SYSTEM_PRIV_APP="$SYSTEM/priv-app"
SYSTEM_ETC_CONFIG="$SYSTEM/etc/sysconfig"
SYSTEM_ETC_DEFAULT="$SYSTEM/etc/default-permissions"
SYSTEM_ETC_PERM="$SYSTEM/etc/permissions"
SYSTEM_ETC_PREF="$SYSTEM/etc/preferred-apps"
SYSTEM_FRAMEWORK="$SYSTEM/framework"
SYSTEM_OVERLAY="$SYSTEM/product/overlay"

# Cleanup
rm -rf $SYSTEM_APP/ExtShared
rm -rf $SYSTEM_APP/FaceLock
rm -rf $SYSTEM_APP/Google*
rm -rf $SYSTEM_PRIV_APP/ConfigUpdater
rm -rf $SYSTEM_PRIV_APP/ExtServices
rm -rf $SYSTEM_PRIV_APP/*Gms*
rm -rf $SYSTEM_PRIV_APP/Google*
rm -rf $SYSTEM_PRIV_APP/Phonesky
rm -rf $SYSTEM_ETC_CONFIG/*google*
rm -rf $SYSTEM_ETC_DEFAULT/default-permissions.xml
rm -rf $SYSTEM_ETC_DEFAULT/bitgapps-permissions.xml
rm -rf $SYSTEM_ETC_DEFAULT/bitgapps-permissions-q.xml
rm -rf $SYSTEM_ETC_PERM/*google*
rm -rf $SYSTEM_ETC_PREF/google.xml
rm -rf $SYSTEM_OVERLAY/PlayStoreOverlay.apk
rm -rf $SYSTEM_ADDOND/70-bitgapps.sh

# Google Apps Packages
ui_print "- Installing GApps"
if [ "$BOOTMODE" = "false" ]; then
  for f in $BITGAPPS; do unzip -oq "$ZIPFILE" "$f" -d "$TMP"; done
fi
# Allow unpack, when installation base is Magisk
if [[ "$(getprop "sys.bootmode")" = "2" ]]; then
  for f in $BITGAPPS; do $(unzip -oq "$ZIPFILE" "$f" -d "$TMP"); done
fi
tar -xf $ZIP_FILE/sys/GoogleCalendarSyncAdapter.tar.xz -C $TMP_SYS
tar -xf $ZIP_FILE/sys/GoogleContactsSyncAdapter.tar.xz -C $TMP_SYS
tar -xf $ZIP_FILE/sys/GoogleExtShared.tar.xz -C $TMP_SYS
tar -xf $ZIP_FILE/core/ConfigUpdater.tar.xz -C $TMP_PRIV
tar -xf $ZIP_FILE/core/GmsCoreSetupPrebuilt.tar.xz -C $TMP_PRIV 2>/dev/null
tar -xf $ZIP_FILE/core/GoogleExtServices.tar.xz -C $TMP_PRIV
tar -xf $ZIP_FILE/core/GoogleLoginService.tar.xz -C $TMP_PRIV 2>/dev/null
tar -xf $ZIP_FILE/core/GoogleServicesFramework.tar.xz -C $TMP_PRIV
tar -xf $ZIP_FILE/core/Phonesky.tar.xz -C $TMP_PRIV
tar -xf $ZIP_FILE/core/PrebuiltGmsCore.tar.xz -C $TMP_PRIV
tar -xf $ZIP_FILE/Sysconfig.tar.xz -C $TMP_SYSCONFIG
tar -xf $ZIP_FILE/Default.tar.xz -C $TMP_DEFAULT
tar -xf $ZIP_FILE/Permissions.tar.xz -C $TMP_PERMISSION
tar -xf $ZIP_FILE/Preferred.tar.xz -C $TMP_PREFERRED
tar -xf $ZIP_FILE/overlay/PlayStoreOverlay.tar.xz -C $TMP_OVERLAY 2>/dev/null
# Remove Compressed Packages
for f in $BITGAPPS; do rm -rf $TMP/$f; done

# REQUEST NETWORK SCORES
if [ "$android_sdk" -le "28" ]; then
  rm -rf $TMP_DEFAULT/bitgapps-permissions-q.xml
fi
if [ "$android_sdk" -ge "29" ]; then
  rm -rf $TMP_DEFAULT/bitgapps-permissions.xml
fi

# Additional Components
if [ "$BOOTMODE" = "false" ]; then
  for f in $FRAMEWORK; do unzip -oq "$ZIPFILE" "$f" -d "$TMP"; done
fi
# Allow unpack, when installation base is Magisk
if [[ "$(getprop "sys.bootmode")" = "2" ]]; then
  for f in $FRAMEWORK; do $(unzip -oq "$ZIPFILE" "$f" -d "$TMP"); done
fi
tar -xf $ZIP_FILE/framework/DialerPermissions.tar.xz -C $TMP_PERMISSION
tar -xf $ZIP_FILE/framework/DialerFramework.tar.xz -C $TMP_FRAMEWORK
tar -xf $ZIP_FILE/framework/MapsPermissions.tar.xz -C $TMP_PERMISSION
tar -xf $ZIP_FILE/framework/MapsFramework.tar.xz -C $TMP_FRAMEWORK

# Install OTA Survival Script
if [ -d "$SYSTEM_ADDOND" ]; then
  ui_print "- Installing OTA survival script"
  ADDOND="70-bitgapps.sh"
  if [ "$BOOTMODE" = "false" ]; then
    unzip -oq "$ZIPFILE" "$ADDOND" -d "$TMP"
  fi
  # Allow unpack, when installation base is Magisk
  if [[ "$(getprop "sys.bootmode")" = "2" ]]; then
    $(unzip -oq "$ZIPFILE" "$ADDOND" -d "$TMP")
  fi
  # Install OTA survival script
  rm -rf $SYSTEM_ADDOND/$ADDOND
  cp -f $TMP/$ADDOND $SYSTEM_ADDOND/$ADDOND
  chmod 0755 $SYSTEM_ADDOND/$ADDOND
  ch_con system "$SYSTEM_ADDOND/$ADDOND"
fi

# Allow SetupWizard to survive OTA upgrade
if [ "$supported_setup_config" = "true" ]; then
  sed -i -e 's/"false"/"true"/g' $SYSTEM_ADDOND/$ADDOND
fi

# Install SetupWizard Components
if [ "$supported_setup_config" = "true" ]; then
  ui_print "- Installing SetupWizard"
  for f in $SYSTEM $SYSTEM/product $SYSTEM/system_ext $P; do
    find $f -type d -name '*MigratePre*' -exec $rm -rf {} +
    find $f -type d -name '*GoogleBackup*' -exec $rm -rf {} +
    find $f -type d -name '*GoogleRestore*' -exec $rm -rf {} +
    find $f -type d -name '*SetupWizard*' -exec $rm -rf {} +
    find $f -type d -name '*Provision*' -exec $rm -rf {} +
  done
  if [ "$BOOTMODE" = "false" ]; then
    for f in $SETUPWIZARD; do unzip -oq "$ZIPFILE" "$f" -d "$TMP"; done
  fi
  # Allow unpack, when installation base is Magisk
  if [[ "$(getprop "sys.bootmode")" = "2" ]]; then
    for f in $SETUPWIZARD; do $(unzip -oq "$ZIPFILE" "$f" -d "$TMP"); done
  fi
  if [ -f "$ZIP_FILE/core/GoogleBackupTransport.tar.xz" ]; then
    tar -xf $ZIP_FILE/core/GoogleBackupTransport.tar.xz -C $TMP_PRIV
  fi
  if [ -f "$ZIP_FILE/core/GoogleRestore.tar.xz" ]; then
    tar -xf $ZIP_FILE/core/GoogleRestore.tar.xz -C $TMP_PRIV
  fi
  tar -xf $ZIP_FILE/core/SetupWizardPrebuilt.tar.xz -C $TMP_PRIV
  # Remove Compressed Packages
  for f in $SETUPWIZARD; do rm -rf $TMP/$f; done
fi

# Integrity Signing Certificate
FSVERITY="$SYSTEM/etc/security/fsverity"
if [ -d "$FSVERITY" ]; then
  if [ "$BOOTMODE" = "false" ]; then
    unzip -oq "$ZIPFILE" "zip/Certificate.tar.xz" -d "$TMP"
  fi
  # Allow unpack, when installation base is Magisk
  if [[ "$(getprop "sys.bootmode")" = "2" ]]; then
    $(unzip -oq "$ZIPFILE" "zip/Certificate.tar.xz" -d "$TMP")
  fi
  # Integrity Signing Certificate
  tar -xf $ZIP_FILE/Certificate.tar.xz -C "$FSVERITY"
  chmod 0644 $FSVERITY/gms_fsverity_cert.der
  chmod 0644 $FSVERITY/play_store_fsi_cert.der
  ch_con system "$FSVERITY/gms_fsverity_cert.der"
  ch_con system "$FSVERITY/play_store_fsi_cert.der"
fi

# Helper Functions
extracted
on_installed

# End installation
