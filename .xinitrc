#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap
xbacklight -set 5
wmname LG3D &

nitrogen --restore &

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f $userresources ]; then
    xrdb -merge $userresources
fi

if [ -f $usermodmap ]; then
    xmodmap $usermodmap
fi

/usr/bin/xdg-user-dirs-update

env_vars_path="$HOME/.env_vars"

rm -f "${env_vars_path}"
touch "${env_vars_path}"
chmod 600 "${env_vars_path}"

# Array of the environment variables.
env_vars=("DBUS_SESSION_BUS_ADDRESS" "XAUTHORITY" "DISPLAY")

for env_var in "${env_vars[@]}"
do
    echo "$env_var"
    env | grep "${env_var}" >> "${env_vars_path}";
    echo "export ${env_var}" >> "${env_vars_path}";
done


while true; do
   BAT=$(cat /sys/class/power_supply/BAT0/capacity)
   CHR=$(cat /sys/class/power_supply/BAT0/status)
   CLK=$( date +'%I:%M %P')
   VOL=$( amixer get Master | tail -1 | awk '{ print $5}' | tr -d '[]' )
   xsetroot -name "Vol:$VOL | Bat:$BAT% ($CHR) | $CLK"  
   sleep 1    # Update time every minute
done &

while true; do
LOW_BATTERY="15"
BATTERY_PATH="/sys/class/power_supply/BAT0/"

if [ -e "$BATTERY_PATH" ]; then
    BATTERY_ON=$(cat $BATTERY_PATH/status)

    if [ "$BATTERY_ON" == "Discharging" ]; then
        CURRENT_BATTERY=$(cat $BATTERY_PATH/capacity)

        if [ "$CURRENT_BATTERY" -lt "$LOW_BATTERY" ]; then
            notify-send   "Battery is low !!"
        fi
    fi
fi
sleep 1m
done &


xsetroot -solid '#091954'
#xscreensaver -no-splash &
sleep 1;
xset dpms 300 400 500; sleep 1

# Start the window manager:
if [ -z "$DESKTOP_SESSION" -a -x /usr/bin/ck-launch-session ]; then
  exec ck-launch-session /usr/local/bin/dwm
else
  exec /usr/local/bin/dwm
fi



