#!/bin/bash
################## { L O G G I N G } ##################
exec 1> >(logger -s -t $(basename $0)) 2>&1
################## { V A R I A B L E S } ##################
User=$(/usr/bin/who | /usr/bin/grep "console" | /usr/bin/cut -d" " -f1)
DLPath="/Users/$User/Downloads/"
files=$(/bin/ls -1 $DLPath | /usr/bin/grep "\(forms\|frmservlet\).*\.jnlp")
oldfiles=$(/usr/bin/find $DLPath -type f -mmin +3 | /usr/bin/grep  "\(forms\|frmservlet\).*\.jnlp")
validfile=$(/usr/bin/find $DLPath -type f -mmin -3 | /usr/bin/grep  "\(forms\|frmservlet\).*\.jnlp" | sort -r | head -n 1)
forms="https://forms.connect.avondale.edu.au"
uid=$(id -u "$User")
################## { F U N C T I O N S } ##################
function UnlockJNLP() {
    files=$(/bin/ls -1 $DLPath | /usr/bin/grep "\(forms\|frmservlet\).*\.jnlp")
    echo "$files" | while read line; do
    if xattr $DLPath"$line" | grep -q "com.apple.quarantine" ;
        then echo "[D] DEBUG: Discovered File - $line"
            echo "[I] INFO: Extension Attribute Discovered - $line"
            echo "[I] INFO: Removing GateKeeper - $line"
            xattr -d com.apple.quarantine $DLPath"$line"
            if xattr $DLPath"$line" | grep -q "com.apple.quarantine" ;
                then echo "[E] ERROR: Failed to Remove Extension Attribute - $line" >&2 # && exit
                else echo "[I] INFO: Successfully Removed Extension Attribute - $line"
            fi
            else echo "[W] WARN: No JNLP File Present or Extension Attribute Missing" >&2
        fi
	done }
function DelOldFiles() {
    echo "$oldfiles" | while read line; do
        if [ -f "$line" ] ;
            then 
            echo "[I] INFO: Found Expired JNLP - $line"
            echo "[I] INFO: Removing JNLP - $line"
            rm -rf "$line"
            if [ -f "$line" ] ;
                then echo "[E] ERROR: Failed to Remove JNLP - $line" >&2
                else echo "[I] INFO: Successfully Removed JNLP - $line"
            fi
            else echo "[W] WARN: No Expired JNLP Files Discovered. Proceeding..."
        fi
    sleep 2
    done }
function Main() { DelOldFiles ; UnlockJNLP ; OpenJNLP ; DelOpenJNLP ; }
function DownloadJNLP() { launchctl asuser "$uid" sudo -u "$User" open $forms ; sleep 3 ; }
function OpenJNLP() { validfile=$(/usr/bin/find $DLPath -type f -mmin -3 | /usr/bin/grep  "\(forms\|frmservlet\).*\.jnlp" | sort -r | head -n 1) ; sleep 2 ; launchctl asuser "$uid" sudo -u "$User" javaws "$validfile" ;}
function  DelOpenJNLP() { sleep 180 ; rm -rf "$validfile" ; }
################## { P R E - F L I G H T } ##################
if [ -d $DLPath ] ; 
    then cd $DLPath && echo "[I] INFO: User Downloads Directory Exists. Proceeding..."
    else echo "[E] ERROR: Downloads Directory Not Found. Exiting..." >&2 && exit
fi
################## { E X E C U T I O N } ##################
if [ ! -f $DLPath$validfile ] ; then DownloadJNLP ; fi
Main
################## { E N D   O F   F I L E } ##################