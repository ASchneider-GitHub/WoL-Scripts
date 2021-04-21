#!/bin/bash

#Test line ignore

# IP address of target PC
targetPCIP="xxx.xxx.xxx.xxx"
# Broadcast address of network the target PC is on
targetNetBroad="xxx.xxx.xxx.xxx"
# MAC address of target PC's NIC
targetNICMAC="xx:xx:xx:xx:xx:xx"
# Port SleepOnLAN is configured to listen on. Default is 7760
sleepPort="7760"
# Number of failed pings allowed before scripts terminates automatically. Default is 20.
maxPings="20"

echo ""
ping -c 1 -W 1 "$targetPCIP" > /dev/null && echo "Target PC is currently awake!" || echo "Target PC is currently hibernating!"
echo ""
echo "1) Wake it up!"
echo "2) Hibernate it!"
echo "3) Exit the script."
echo "==================="
exitCondition="false"
while [[ "$exitCondition" == "false" ]]; do
	read -p "Would you like to wake target PC up, or hibernate it? > " menuSelection
	if [[ "$menuSelection" == "1" ]]; then
		echo "Waking up the target PC!"
		echo ""
		wakeonlan -i "$targetNetBroad" -p 9 "$targetNICMAC" &> /dev/null
		reply=false
		pingCount=1
		while [[ "$reply" == "false" && "$pingCount" -lt $((maxPings+1)) ]]; do
			echo "Sending ping $pingCount/$maxPings"
			ping -c 1 -W 1 "$targetPCIP" > /dev/null && reply=true || reply=false
			((pingCount++))
			sleep 1
			if [[ "$reply" == "true" ]]; then
				echo ""
				echo "Machine is now awake!"
				exit 0
			elif [[ "$reply" == "false" && "$pingCount" -ge $((maxPings+1)) ]]; then
				echo ""
				echo "Computer is still hibernating. Something may have gone wrong. Feel free to try running the script again."
				exit 0
			fi
		done
	elif [[ "$menuSelection" == "2" ]]; then
		echo "Hibernating target PC!"
		echo ""
		curl http://"$targetPCIP":"$sleepPort"/hibernate &> /dev/null
		reply=true
		pingCount=1
		while [[ "$reply" == "true" && "$pingCount" -lt $((maxPings+1)) ]]; do
			echo "Sending ping $pingCount/$maxPings"
			ping -c 1 -W 1 "$targetPCIP" > /dev/null && reply=true || reply=false
			((pingCount++))
			sleep 1
			if [[ "$reply" == "false" ]]; then
				echo ""
				echo "Machine is now hibernating!"
				exit 0
			elif [[ "$reply" == "true" && "$pingCount" -ge $((maxPings+1)) ]]; then
				echo ""
				echo "Computer is still awake. Something may have gone wrong. Feel free to try running the script again."
			fi
		done
	elif [[ "$menuSelection" == "3" ]]; then
		echo "Exiting..."
		exit 0
	else
		echo "Not a valid selection. Please try again."
	fi
done





# This script allows the user to awaken or hibernate a target machine, specified at the top of the file.
# It also pings the machine up to 20 times to see if awakening/hibernating it was successful.
# If your PC is slow to boot up, you may need to adjust the amount of attempted pings before cancellation
