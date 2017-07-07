ln -s $PWD/xmInit.sh ~
ln -s $PWD/colortest.sh ~
mkdir --parents ~/.xmonad
mkdir --parents ~/.config
mkdir --parents ~/.config/termite
ln -s $PWD/xmonad.hs ~/.xmonad
ln -s $PWD/compton.conf ~/.config
ln -s $PWD/termiteConfig ~/.config/termite/config
ln -s $PWD/.[!.]* ~
rm ~/.git -rf
#mkdir --parents ~/.xmonad/ && mv ./.xmonad/xmonad.hs ~/.xmonad
