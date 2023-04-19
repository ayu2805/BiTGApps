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

. /tmp/backuptool.functions

list_files() {
cat <<EOF
app/Maps/Maps.apk
app/Maps/lib/arm/libarcore_sdk_c.so
app/Maps/lib/arm/libarcore_sdk_jni.so
app/Maps/lib/arm/libgmm-jni.so
app/Maps/lib/arm/libmappedcountercacheversionjni.so
app/Maps/lib/arm/libnative_crash_handler_jni.so
app/Maps/lib/arm64/libarcore_sdk_c.so
app/Maps/lib/arm64/libarcore_sdk_jni.so
app/Maps/lib/arm64/libgmm-jni.so
app/Maps/lib/arm64/libmappedcountercacheversionjni.so
app/Maps/lib/arm64/libnative_crash_handler_jni.so
app/Maps/lib/x86/libarcore_sdk_c.so
app/Maps/lib/x86/libarcore_sdk_jni.so
app/Maps/lib/x86/libgmm-jni.so
app/Maps/lib/x86/libmappedcountercacheversionjni.so
app/Maps/lib/x86/libnative_crash_handler_jni.so
app/Maps/lib/x86_64/libarcore_sdk_c.so
app/Maps/lib/x86_64/libarcore_sdk_jni.so
app/Maps/lib/x86_64/libgmm-jni.so
app/Maps/lib/x86_64/libmappedcountercacheversionjni.so
app/Maps/lib/x86_64/libnative_crash_handler_jni.so
app/GLH/GLH.apk
EOF
}

case "$1" in
  backup)
    list_files | while read FILE DUMMY; do
      backup_file $S/"$FILE"
    done
  ;;
  restore)
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
