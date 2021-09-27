#!/usr/bin/env bash

function run {
	if ! pgrep -f $1 ;
	then
		$@&
	fi
}

# run <program> <args>

run xcompmgr -C -f -r 5 -F -D 3
# run blueman-tray


run redshift -l 38.71667:-9.13333

# run optimus-manager-qt
# touchpad click on tap enable
# run xinput set-prop 12 "libinput Tapping Enabled" 1




