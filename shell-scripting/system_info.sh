#!/bin/bash
# ==============================================================================
# Script Name : system_info.sh
# Description : Displays system information, captures user input, and logs
#               running processes to a file using output redirection.
# Author      : mdkaif
# DevOps Homework - Shell Scripting Task
# ==============================================================================

# Clear terminal for clean presentation
clear

echo "=================================================="
echo "          SYSTEM INFORMATION DASHBOARD            "
echo "=================================================="

# ------------------------------------------------------------------------------
# 1. Variables to store system details
# ------------------------------------------------------------------------------
CURRENT_DATE=$(date)
HOST_NAME=$(hostname)
USER_NAME=$(whoami)

# ------------------------------------------------------------------------------
# 2. Print Basic System Details using variables
# ------------------------------------------------------------------------------
echo ""
echo "[+] Basic Information:"
echo "--------------------------------------------------"
echo "Current Date & Time : $CURRENT_DATE"
echo "Host Name           : $HOST_NAME"
echo "Logged-in Username  : $USER_NAME"

# ------------------------------------------------------------------------------
# 3. Print Disk Usage (df)
# ------------------------------------------------------------------------------
echo ""
echo "[+] Filesystem Disk Usage (df -h):"
echo "--------------------------------------------------"
df -h

# ------------------------------------------------------------------------------
# 4. Print Running Processes (ps)
# ------------------------------------------------------------------------------
echo ""
echo "[+] Top Running Processes (ps aux):"
echo "--------------------------------------------------"
ps aux | head -n 10

# ------------------------------------------------------------------------------
# 5. User Input using read -p
# ------------------------------------------------------------------------------
echo ""
echo "=================================================="
echo "          LOG DIRECTORY & FILE CREATION           "
echo "=================================================="
read -p "Enter directory name to create for logs: " DIR_NAME
read -p "Enter filename to store process list (e.g., processes.txt): " FILE_NAME

# Fallback defaults if user provides empty input
if [ -z "$DIR_NAME" ]; then
    DIR_NAME="process_logs"
fi

if [ -z "$FILE_NAME" ]; then
    FILE_NAME="running_processes.txt"
fi

# ------------------------------------------------------------------------------
# 6. Create Directory using mkdir
# ------------------------------------------------------------------------------
echo ""
echo "[+] Creating directory: $DIR_NAME"
mkdir -p "$DIR_NAME"

# ------------------------------------------------------------------------------
# 7. Create File using touch
# ------------------------------------------------------------------------------
TARGET_FILE="$DIR_NAME/$FILE_NAME"
echo "[+] Creating file using touch: $TARGET_FILE"
touch "$TARGET_FILE"

# ------------------------------------------------------------------------------
# 8. Store Running Processes into file using > Output Redirection
# ------------------------------------------------------------------------------
echo "[+] Writing running processes to $TARGET_FILE using > output redirection..."
ps aux > "$TARGET_FILE"

# ------------------------------------------------------------------------------
# 9. Verify and Confirm Output
# ------------------------------------------------------------------------------
echo ""
echo "=================================================="
echo "                   VERIFICATION                   "
echo "=================================================="
echo "Directory created: $(ls -ld "$DIR_NAME")"
echo "File created     : $(ls -lh "$TARGET_FILE")"
echo "Total lines saved: $(wc -l < "$TARGET_FILE") processes logged"
echo ""
echo "Preview of the created file (first 5 lines):"
echo "--------------------------------------------------"
head -n 5 "$TARGET_FILE"
echo "--------------------------------------------------"
echo "Script executed successfully!"
echo "=================================================="
