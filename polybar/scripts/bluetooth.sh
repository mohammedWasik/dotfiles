#!/bin/bash

# Check if Bluetooth is available and powered on
bluetooth_print() {
    # First check if Bluetooth is blocked
    if rfkill list bluetooth 2>/dev/null | grep -q "Soft blocked: yes"; then
        echo " Blocked"
        return
    fi
    
    # Check if there's a Bluetooth controller
    if bluetoothctl show 2>/dev/null | grep -q "Controller"; then
        if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
            # Bluetooth is on, check if any device is connected
            connected_device=$(bluetoothctl devices Connected 2>/dev/null | head -1)
            
            if [ ! -z "$connected_device" ]; then
                # Extract device name
                device_name=$(echo "$connected_device" | cut -d' ' -f3-)
                echo " $device_name"
            else
                echo " BT"
            fi
        else
            echo " Off"
        fi
    else
        echo " N/A"
    fi
}

bluetooth_print