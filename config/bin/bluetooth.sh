#!/bin/sh

if [ "$(bluetoothctl show | grep "Powered: yes" | wc -c)" -eq 0 ]; then
  echo "%{F#666666} Power off"
else
  connected_device=$(bluetoothctl info | awk '/Device/ {print $2}')

  if [ -z "$connected_device" ]; then
    echo "%{F#000000} Power on"
  else
    #device_name=$(bluetoothctl info "$connected_device" | awk '/Name/ {print $2}')
        #device_name=$(bluetoothctl devices | awk '/Connected/ {for(i=3; i<=NF; i++) printf("%s", (i>3 ? OFS : "" ) $i); print ""}' | cut -d' ' -f1})
    device_name=$(bluetoothctl devices Connected | awk -vORS=', ' '{for(i=3;i<=NF;i++){ printf("%s",( (i>3) ? OFS : "" ) $i) };print"";}' | sed -e 's/, $/\n/')
    echo "%{F#000000} $device_name"
  fi
fi
