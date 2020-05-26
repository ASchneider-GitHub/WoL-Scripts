#!/bin/bash

# Configured DDNS URL. Can also be network's public IP address if one isn't configured
DDNS="example.ddns.net"
# Port number used for SSH. Default is 22.
portNumber="22"

ssh -l pi "$DDNS" -p "$portNumber"





# This single command opens an SSH session with your RasPi.
# Made into a script for simplicity's sake
