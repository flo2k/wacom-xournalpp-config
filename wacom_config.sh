#!/bin/bash

toggle_touch_ring_behaviour=0
verbose=1
map_to_display=0
initialise=0
while getopts htvmi opt; do
    case $opt in
        h )
            echo "Usage $0 [-h] [-t] [-v] [-i]"
            echo ""
            echo "Options:"
            echo "    -h    show this help"
            echo "    -t    toggle touch ring behaviour"
            echo "    -v    verbose output"
            echo "    -m    map to display output"
            echo "    -i    initialise all states"
            exit 0
            ;;
        t )
            toggle_touch_ring_behaviour=1
            ;;
        v ) 
            verbose=1
            ;;
        m ) 
            map_to_display=1
            ;;
        i ) 
            initialise=1
            ;;
    esac
done
shift "$((OPTIND-1))"   # Discard the options and sentinel --

function do_log(){
    echo "$(date --rfc-3339=seconds) $@" >> ~/.wacom/wacom_log.log
}

function do_log_verbose(){
    if [ $verbose -eq 1 ]; then
        do_log $@
    fi
}

if [ $map_to_display -eq 1 ]; then
    for i in $(xinput | grep Wacom | cut -d'=' -f2 | egrep -o '^[[:digit:]]{1,3}')
    do
        do_log_verbose "map $i to output DP-5"
        xinput map-to-output $i DP-5
    done
fi

#device
DEVICE="Wacom Intuos Pro M"

DEV_STYLUS="$DEVICE Pen stylus"
DEV_ERASER="$DEVICE Pen eraser"
DEV_CURSOR="$DEVICE Pen cursor"
DEV_PAD="$DEVICE Pad pad"
DEV_TOUCH="$DEVICE Finger touch"

#find touch ring led state
wacom_led_file=$(find /sys/devices/pci* -name "status_led0_select")
if [ -e "$wacom_led_file" ]; then
    state=$(cat $(find /sys/devices/pci* -name "status_led0_select"))
else
    #handling for bluetooth connection
    if [ $initialise -eq 1 ]; then
        state=0
    else
        state=$(cat ~/.wacom/.wacom_touch_ring_state)
    fi

    if [ -z "$state" ]; then
        state=0
    fi

    if [ $toggle_touch_ring_behaviour -eq 1 ]; then
        state=$[$state+1]
        state=$[$state%4]
        do_log_verbose "toggle ring behaviour $state"
    fi

    echo $state > ~/.wacom/.wacom_touch_ring_state
fi

do_log_verbose "led state $state"



## Stylus

## Eraser

## Pad - Keys
xsetwacom set "$DEV_PAD" "Button" "1"  "key +Control_L +Prior -Prior "   # Page up
xsetwacom set "$DEV_PAD" "Button" "2"  "key +Control_L +Next -Next "     # Page down

xsetwacom set "$DEV_PAD" "Button" "3"  "key +Control_L +y -y "           # Redo
xsetwacom set "$DEV_PAD" "Button" "8"  "key +Control_L +z -z "           # Undo

xsetwacom set "$DEV_PAD" "Button" "9"  "key +Shift_L "                   # Shift
xsetwacom set "$DEV_PAD" "Button" "10" "key +Control_L "                 # Ctrl
xsetwacom set "$DEV_PAD" "Button" "11" "key +Alt "                       # Alt

## Pad - Touch ring
case $state in
    0)
        do_log_verbose "touch ring: scroll enabled"
        xsetwacom set "$DEV_PAD" "AbsWheelDown" "button +4"  # Scroll up
        xsetwacom set "$DEV_PAD" "AbsWheelUp"   "button +5"  # Scroll down
        ;;
    1)
        do_log_verbose "touch ring: zoom enabled"
        xsetwacom set "$DEV_PAD" "AbsWheelDown" "key +Control_L button +4"  # Zoom out
        xsetwacom set "$DEV_PAD" "AbsWheelUp"   "key +Control_L button +5"  # Zoom in
        ;;
    2)
        do_log_verbose "touch ring: disabled"
        xsetwacom set "$DEV_PAD" "AbsWheelDown" "button 0"  # Disabled
        xsetwacom set "$DEV_PAD" "AbsWheelUp"   "button 0"  # Disabled
        ;;
    3)
        do_log_verbose "touch ring: disabled"
        xsetwacom set "$DEV_PAD" "AbsWheelDown" "button 0"  # Disabled
        xsetwacom set "$DEV_PAD" "AbsWheelUp"   "button 0"  # Disabled
        ;;
    *)
        do_log_verbose "touch ring: disabled"
        xsetwacom set "$DEV_PAD" "AbsWheelDown" "button 0"  # Disabled
        xsetwacom set "$DEV_PAD" "AbsWheelUp"   "button 0"  # Disabled
        ;;
esac

## Finger touch
xsetwacom set "$DEV_TOUCH" "Touch" "on"
xsetwacom set "$DEV_TOUCH" "Gesture" "on"
xsetwacom set "$DEV_TOUCH" "ZoomDistance" "500"
xsetwacom set "$DEV_TOUCH" "ScrollDistance" "200"
xsetwacom set "$DEV_TOUCH" "TapTime" "250"