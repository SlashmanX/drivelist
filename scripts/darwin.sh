#!/bin/sh

function get_key {
  grep "$1" | awk -F "  +" '{ print $3 }'
}

function get_until_paren {
  awk 'match($0, "\\(|$"){ print substr($0, 0, RSTART - 1) }'
}

function get_until_on {
  awk 'match($0, "on"){ print substr($0, 0, RSTART - 1) }'
}

DISKS="`mount | get_until_on`"

for disk in $DISKS; do
  diskinfo="`diskutil info $disk`"

  device=`echo "$diskinfo" | get_key "Device Node"`
  description=`echo "$diskinfo" | get_key "Device / Media Name"`
  name=`echo "$diskinfo" | get_key "Volume Name"`
  mountpoint=`echo "$diskinfo" | get_key "Mount Point"`
  size=`echo "$diskinfo" | get_key "Total Size" | get_until_paren`
  freespace=`echo "$diskinfo" | get_key "Volume Free Space" | get_until_paren`
  uuid=`echo "$diskinfo" | get_key "Volume UUID"`

  echo "device: $device"
  echo "description: $description"
  echo "name: $name"
  echo "size: $size"
  echo "freespace: $freespace"
  echo "mountpoint: $mountpoint"
  echo "uuid: $uuid"

  if [[ "$device" == "/dev/disk0" ]] || [[ "$mountpoint" == "/" ]]; then
    echo "system: True"
  else
    echo "system: False"
  fi

  echo ""
done
