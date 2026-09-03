#!/bin/bash

# 1. Variables storing system data
CURRENT_DATE=$(date)
MY_HOSTNAME=$(hostname)
MY_USER=$(whoami)

# 2. Print system information
echo "Current Date: $CURRENT_DATE"
echo "Hostname: $MY_HOSTNAME"
echo "Username: $MY_USER"

# 3. Print disk usage
echo "--- Disk Usage ---"
df -h

# 4. Print running processes
echo "--- Running Processes ---"
ps aux | head -15

# 5. User input using read -p
read -p "Enter directory name: " DIR_NAME
read -p "Enter file name: " FILE_NAME

# 6. Create directory using mkdir
mkdir -p "$DIR_NAME"

# 7. Create file using touch
touch "$DIR_NAME/$FILE_NAME"

# 8. Store running processes using > output redirection
ps aux > "$DIR_NAME/$FILE_NAME"

echo "Process info saved to $DIR_NAME/$FILE_NAME"
