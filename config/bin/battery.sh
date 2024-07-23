#!/bin/bash

while true; do
    # Obtener el nivel de la batería actual
    battery_level=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)

    # Obtener el estado del cargador (1: conectado, 0: desconectado)
    charger_status=$(cat /sys/class/power_supply/ACAD/online 2>/dev/null)

    # Comprobar si se obtuvo el nivel de batería
    if [ -z "$battery_level" ]; then
        echo "Advertencia: No se pudo obtener información de la batería."
        sleep 300
        continue
    fi

    # Comprobar si la batería está al 20% o menos y el cargador está desconectado
    if [ "$battery_level" -le 20 ] && [ "$charger_status" == "0" ]; then
           ~/.config/bin/battery.py "Por favor. Conecta el cargador." "Nivel de carga: $battery_level%"
    fi

    # Comprobar si la batería está al 100% y el cargador está conectado
    if [ "$battery_level" -eq 100 ] && [ "$charger_status" == "1" ]; then
        ~/.config/bin/battery.py "Por favor. Desconecte el cargador." "Nivel de carga: $battery_level%"
    fi

    # Esperar 5 minutos antes de la próxima verificación
    sleep 300
done
