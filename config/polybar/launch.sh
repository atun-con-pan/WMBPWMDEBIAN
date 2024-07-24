#!/usr/bin/env sh

## Add this to your wm startup file.

# Terminate already running bar instances
killall -q polybar

## Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

## Launch

polybar date -c ~/.config/bspwm/polybar/current.ini &
polybar ram -c ~/.config/bspwm/polybar/current.ini &
polybar ssd -c ~/.config/bspwm/polybar/current.ini &
polybar cpu -c ~/.config/bspwm/polybar/current.ini &
polybar volume -c ~/.config/bspwm/polybar/current.ini &
polybar battery -c ~/.config/bspwm/polybar/current.ini &
polybar wireless -c ~/.config/bspwm/polybar/current.ini &
polybar ip -c ~/.config/bspwm/polybar/current.ini &

## Center bar
polybar primary -c ~/.config/bspwm/polybar/workspace.ini &