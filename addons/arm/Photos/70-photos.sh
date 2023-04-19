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

# Dedicated V3 Partitions
P="/product /system_ext /postinstall/product /postinstall/system_ext"

. /tmp/backuptool.functions

list_files() {
cat <<EOF
app/Photos/Photos.apk
app/Photos/lib/arm/libcronet.102.0.4973.2.so
app/Photos/lib/arm/libfilterframework_jni.so
app/Photos/lib/arm/libflacJNI.so
app/Photos/lib/arm/libframesequence.so
app/Photos/lib/arm/libnative_crash_handler_jni.so
app/Photos/lib/arm/libnative.so
app/Photos/lib/arm/liboliveoil.so
app/Photos/lib/arm/libwebp_android.so
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
      find $f -type d -name '*Gallery*' -exec rm -rf {} +
    done
    list_files | while read FILE REPLACEMENT; do
      R=""
      [ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
      [ -f "$C/$S/$FILE" ] && restore_file $S/"$FILE" "$R"
    done
    for i in $(list_files); do
      chown root:root "$SYS/$i" 2>/dev/null
      chmod 644 "$SYS/$i" 2>/dev/null
      chmod 755 "$(dirname "$SYS/$i")" 2>/dev/null
    done
  ;;
esac
