#!/bin/sh

## From bitrvmpd's SailfishOS port
## Modified by asriel-danctnix (for ubports-santoni)

# Maximum number of attempts to enable hcismd to try to get
# hci0 to come online.  Writing to sysfs too early seems to
# not work, so we loop.
MAXTRIES=15

#setprop bluetooth.hciattach true
setprop ro.qualcomm.bt.hci_transport smd
setprop qcom.bt.dev_power_class 2
setprop qcom.bt.le_dev_pwr_class 2

i=1
while [ ! $i -gt $MAXTRIES ]  ; do
    # set wcnss fwpath first
    echo sta > /sys/module/wlan/parameters/fwpath
    rfkill unblock all
    echo 1 > /sys/module/hci_smd/parameters/hcismd_set
    if [ -e /sys/class/bluetooth/hci0 ] ; then
        rfkill unblock all
        # found hci0, exit successfully
        echo 0 > /sys/module/hci_smd/parameters/hcismd_set
        bt_mac=$(/system/bin/hci_qcomm_init -e -p 2 -P 2 -d /dev/ttyHSL0 2>1 | grep -oP '([0-9a-f]{2}:){5}([0-9a-f]{2})')
        echo "BT MAC: $bt_mac"
        if [ ! -z "$bt_mac" ] ; then
            echo $bt_mac > /var/lib/bluetooth/board-address
            echo "BT MAC: $bt_mac"
        fi
        echo 1 > /sys/module/hci_smd/parameters/hcismd_set
        exit 0
    fi
    sleep 1
    if [ $i == $MAXTRIES ] ; then
        # must have gotten through all our retries, fail
        exit 1
    fi
done
rfkill unblock all
