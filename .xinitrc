[ -f ~/.xprofile ] && . ~/.xprofile
termite &
compton -b &
~/.fehbg &
xscreensaver &


exec xmonad
