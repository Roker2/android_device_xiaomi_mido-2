#!/bin/sh

## Remount root directory as read/write
mount -o remount rw /


## This is run if /lib/firmware doesn't exist
if [ ! -d /lib/firmware ] ; then
	mkdir -p /lib/firmware || true
	
	# Symlink the firmware files and reboot to take effect
	ln -s /firmware/image/* /lib/firmware/
	sleep 2
	reboot
fi
