#!/bin/zsh
################## { L O G G I N G } ##################
exec 1> >(logger -s -t $(basename $0)) 2>&1
################## { V A R I A B L E S } ##################
logged_in_user=$(who | grep "console" | cut -d" " -f1)
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
uid=$(id -u "$logged_in_user")
user_home=$(dscl . -read /users/$logged_in_user NFSHomeDirectory | cut -d " " -f 2)
defaults=$("/usr/bin/defaults")
cc="ControlCenter"
mb="MenuBar"
################## { F U N C T I O N S } ##################
function CTLCTR_READ () {(launchctl asuser $uid $defaults read "$user_home"/Library/Preferences/ByHost/com.apple.controlcenter.plist ScreenMirroring)}
function CTLCTR_WRITE () {(launchctl asuser $uid $defaults write "$user_home"/Library/Preferences/ByHost/com.apple.controlcenter.plist ScreenMirroring -int 18)}
function MENUBAR_READ () {(launchctl asuser $uid /usr/bin/defaults read "$user_home"/Library/Preferences/com.apple.airplay.plist showInMenuBarIfPresent)}
function MENUBAR_WRITE () {(launchctl asuser $uid /usr/bin/defaults write "$user_home"/Library/Preferences/com.apple.airplay.plist showInMenuBarIfPresent -bool true)}
function CTLCTR() {
if $(CTLCTR_READ) == "18"
    then echo "[W] WARN: $cc PLIST Already Configured. Proceeding..."
    else echo "[I] INFO: $cc PLIST is default. Proceeding..."
        echo "[I] INFO: Setting $cc PLIST"
        $(CTLCTR_WRITE)
        if $(CTLCTR_READ) == "18"
            then echo "[E] ERROR: Failed to Set $cc PLIST" >&2 # && exit
            else echo "[I] INFO: Successfully Set $cc PLIST"
        fi
fi }
function MenuBar() {
if $(MENUBAR_READ) == "1"
    then echo "[W] WARN: $mb PLIST Already Configured. Proceeding..."
    else echo "[I] INFO: $mb PLIST is default. Proceeding..."
        echo "[I] INFO: Setting $mb PLIST"
        $(MENUBAR_WRITE)
        if $(MENUBAR_READ) == "1"
            then echo "[E] ERROR: Failed to Set $mb PLIST" >&2 # && exit
            else echo "[I] INFO: Successfully Set $mb PLIST"
        fi
fi }
function Refresh() {( launchctl asuser $uid echo "[I] INFO: Restarting ControlCenter..." && killall "$cc" )}
function Main() { CTLCTR ; MenuBar ; Refresh ;}
################## { P R E - F L I G H T } ##################
################## { E X E C U T I O N } ##################
Main
################## { E N D   O F   F I L E } ##################