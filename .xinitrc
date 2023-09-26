#!/bin/bash

# TODO: refactor such that everything is reloaded when dwm quits
# while (logoutfile doesnt exist)
#   cleanup and trap (cleanup) on exit
#     - exit prev xautolock if there is a pid
#     - exit prev status monitor if there is a pid
#     - exit prev battery monitor if there is a pid
#   process x resources
#   spawn background processes:
#     - xautolock
#     - statusbar updater
#     - battery monitor
#   configure hidpi
#   update bg
#   start dwm

## ---- X RESOURCES

# merge in defaults and keymaps

sysresources=/etc/X11/xinit/.Xresources
[ -f $sysresources ] && xrdb -merge $sysresources

sysmodmap=/etc/X11/xinit/.Xmodmap
[ -f $sysmodmap ] && xrdb -merge $sysmodmap

userresources=$HOME/.Xresources
[ -f "$userresources" ] && xrdb -merge "$userresources"

usermodmap=$HOME/.Xmodmap
[ -f "$usermodmap" ] && xrdb -merge "$usermodmap"

# start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do [ -x "$f" ] && "$f"; done
 unset f
fi

## ---- WINDOW MANAGER

# load keybindings
xbindkeys

# screen saver
xautolock -time 10 -locker 'slock -m "$(cowthink -f $(find /usr/share/cows -type f | egrep .cow$ | shuf -n 1) $(fortune -a))"' &
xautolockprocpid=$!
trap 'kill "$xautolockprocpid"' EXIT
 
# update status in statusbar every 1 second
while true; do "$HOME/.scripts/check-status" update-statusbar; sleep 1; done &
statusprocpid=$!
trap 'kill "$statusprocpid"' EXIT
 
# check battery level every 10 seconds
while true; do "$HOME/.scripts/check-battery" notify; sleep 10; done &
notifsprocpid=$!
trap 'kill "$notifsprocpid"' EXIT
 
# logout lock
logoutlocpath="$HOME/.logout"
trap 'rm $logoutlocpath &>/dev/null' EXIT

# start touchegg-client
touchegg &
toucheggprocpid=$!
trap 'kill "$toucheggprocpid"' EXIT

# start dwm (restart dwm without loosing x session)
while [ ! -f "$logoutlocpath" ]; do
  # hidpi
  # export GDK_DPI_SCALE=0.5
  export GDK_DPI_SCALE=1

  # key mods
  [[ -f $HOME/.Xmodmap ]] && xmodmap ~/.Xmodmap

  # desktop bg
  feh --bg-scale "$HOME/.bg.jpg"
  
  # Log stderror to a file
  dwm 2> ~/.dwm.log
done
