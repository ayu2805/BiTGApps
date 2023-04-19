#!/system/bin/sh
#
# This file is part of The BiTGApps Project

id=`id`; id=`echo ${id#*=}`; id=`echo ${id%%\(*}`; id=`echo ${id%% *}`
if [ "$id" != "0" ] && [ "$id" != "root" ]; then
  sleep 1
  printf '\n%.0s'
  echo "You are NOT running as root..."
  printf '\n%.0s'
  sleep 1
  printf '\n%.0s'
  echo "Please type 'su' first before typing 'bootmode.sh'..."
  printf '\n%.0s'
  exit 1
fi

# Default Permission
umask 022

# Manipulate SELinux State
setenforce 0

# Create temporary directory
export TMP="/dev/tmp" && install -d $TMP

if [ ! -d "/data/adb/magisk" ]; then
  echo "! Magisk not installed. Aborting..."
  exit 1
fi

if [ ! -f "/data/adb/magisk/busybox" ]; then
  echo "! Busybox not found. Aborting..."
  exit 1
fi

# Set busybox standalone mode
export ASH_STANDALONE=1

# Set busybox in the global environment
export BB="/data/adb/magisk/busybox"

if [ ! -f /data/adb/magisk/util_functions.sh ]; then
  echo "! Please install Magisk v20.4+"
  exit 1
fi

if [ -f /data/adb/magisk/util_functions.sh ]; then
  UF="/data/adb/magisk/util_functions.sh"
  grep -w 'MAGISK_VER_CODE' $UF >> $TMP/VER_CODE
  chmod 0755 $TMP/VER_CODE && . $TMP/VER_CODE
  if [ "$MAGISK_VER_CODE" -lt "20400" ]; then
    echo "! Please install Magisk v20.4+"
    exit 1
  fi
fi

# Magisk Current Base Folder
MIRROR="$(magisk --path)/.magisk/mirror"

# Installation base is bootmode script not Magisk
if [[ "$(getprop "sys.boot_completed")" = "1" ]]; then
  setprop sys.bootmode "1"
fi

echo $divider
$BB echo -e "========= BiTGApps Installer ========="
$BB echo -e "1. Construct Install Environment      "
$BB echo -e "2. Install BiTGApps Package           "
$BB echo -e "3. Reboot                             "
$BB echo -e "4. Exit                               "
echo $divider

echo -n "Please select an option [1-4]: "
read option

if [ "$option" = "1" ]; then
  clear
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
  # Global Environment
  export PATH=/data/BiTGApps:$PATH
  # Set installation layout
  export SYSTEM="$MIRROR/system"
  # Backup installation layout
  export SYSTEM_AS_SYSTEM="$SYSTEM"
  # Run script again
  bootmode.sh
elif [ "$option" = "2" ]; then
  clear
  ZIPLIST="/data/media/0/BiTGApps"
  $BB echo -e "Select BiTGApps Package"
  files=$(ls $ZIPLIST/*.zip | cut -d'/' -f6-); i=1
  for j in $files
  do
    echo "$i.$j"; file[i]=$j; i=$(( i + 1 ))
  done
  echo $divider
  $BB echo -e "Enter number from above list"
  read input
  clear
  export ZIPFILE="${file[$input]}"
  echo "Package: $ZIPLIST/${file[$input]}"
  $(unzip -oq "$ZIPLIST/${file[$input]}" -x 'META-INF/*' -d "$TMP")
  sleep 1
  clear
  if [ -f "$TMP/installer.sh" ]; then
    exec $BB sh $TMP/installer.sh "$@"
  fi
  # Remove temporary directory
  rm -rf /dev/tmp
  # Global Environment
  export PATH=/data/BiTGApps:$PATH
  # Run script again
  bootmode.sh
elif [ "$option" = "3" ]; then
  clear
  $BB echo -e "Rebooting Now"
  sleep 1
  reboot
elif [ "$option" = "4" ]; then
  clear
  exit 1
else
  clear
  echo $divider
  $BB echo -e "Invalid option, please try again !"
  echo $divider
  sleep 1
  clear
  # Global Environment
  export PATH=/data/BiTGApps:$PATH
  # Run script again
  bootmode.sh
fi
