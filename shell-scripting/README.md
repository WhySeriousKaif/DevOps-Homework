# Shell Scripting: System Information Script

A hands-on Bash automation script that collects vital system metrics, captures user input interactively, and manages filesystem logs using output redirection.

---

## Table of Contents

- [Task Overview](#task-overview)
- [Required Commands & Features](#required-commands--features)
- [Script Source Code](#script-source-code)
- [Code Breakdown & Explanation](#code-breakdown--explanation)
- [How to Run the Script](#how-to-run-the-script)
- [Sample Execution Output](#sample-execution-output)
- [Practical Evidence & Screenshots](#practical-evidence--screenshots)
- [Key Learnings](#key-learnings)

---

## Task Overview

The objective is to create a shell script (`system_info.sh`) that demonstrates core shell scripting and automation fundamentals:
1. Displays the current date and time.
2. Displays the system hostname.
3. Displays the current logged-in username.
4. Reports filesystem disk usage.
5. Displays actively running processes.
6. Uses variables to store and retrieve system data dynamically.
7. Prompts for user input interactively using `read -p`.
8. Creates a target log directory dynamically using `mkdir`.
9. Creates an empty file using `touch`.
10. Redirects full running process data into the newly created file using `>` output redirection.

---

## Required Commands & Features

| Command / Feature | Purpose in Script | Example Syntax |
|---|---|---|
| `echo` | Prints formatted status messages and headers | `echo "Current Date: $CURRENT_DATE"` |
| `read -p` | Prompts user interactively for directory and file names | `read -p "Enter directory name: " DIR_NAME` |
| **Variables** | Stores command outputs and user-supplied strings | `CURRENT_DATE=$(date)` |
| `df` | Inspects filesystem disk space availability | `df -h` |
| `ps` | Queries system processes | `ps aux \| head -n 10` |
| `mkdir` | Creates the directory for saving output logs | `mkdir -p "$DIR_NAME"` |
| `touch` | Creates or touches the target log file | `touch "$TARGET_FILE"` |
| `> Redirection` | Overwrites/writes command output directly to a file | `ps aux > "$TARGET_FILE"` |

---

## Script Source Code

The full script is maintained at [`system_info.sh`](./system_info.sh):

```bash
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

# 1. Variables to store system details
CURRENT_DATE=$(date)
HOST_NAME=$(hostname)
USER_NAME=$(whoami)

# 2. Print Basic System Details using variables
echo ""
echo "[+] Basic Information:"
echo "--------------------------------------------------"
echo "Current Date & Time : $CURRENT_DATE"
echo "Host Name           : $HOST_NAME"
echo "Logged-in Username  : $USER_NAME"

# 3. Print Disk Usage (df)
echo ""
echo "[+] Filesystem Disk Usage (df -h):"
echo "--------------------------------------------------"
df -h

# 4. Print Running Processes (ps)
echo ""
echo "[+] Top Running Processes (ps aux):"
echo "--------------------------------------------------"
ps aux | head -n 10

# 5. User Input using read -p
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

# 6. Create Directory using mkdir
echo ""
echo "[+] Creating directory: $DIR_NAME"
mkdir -p "$DIR_NAME"

# 7. Create File using touch
TARGET_FILE="$DIR_NAME/$FILE_NAME"
echo "[+] Creating file using touch: $TARGET_FILE"
touch "$TARGET_FILE"

# 8. Store Running Processes into file using > Output Redirection
echo "[+] Writing running processes to $TARGET_FILE using > output redirection..."
ps aux > "$TARGET_FILE"

# 9. Verify and Confirm Output
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
```

---

## Code Breakdown & Explanation

### 1. Variables & Command Substitution
```bash
CURRENT_DATE=$(date)
HOST_NAME=$(hostname)
USER_NAME=$(whoami)
```
- The `$(command)` syntax executes the command in a subshell and assigns its standard output to the variable.
- Calling `$CURRENT_DATE`, `$HOST_NAME`, and `$USER_NAME` later in the script allows clean reuse without re-running system commands multiple times.

### 2. Monitoring Disk Usage (`df -h`)
- `df` inspects filesystems. The `-h` flag formats disk blocks into human-readable units (KB, MB, GB).

### 3. Monitoring Running Processes (`ps aux`)
- `ps` lists current active processes.
- The `aux` flags display processes for all users (`a`), including terminal-less background daemons (`x`), along with the username owning the process (`u`).
- Piped into `head -n 10` so the console output remains readable and focused on high-priority processes.

### 4. Interactive Prompting (`read -p`)
```bash
read -p "Enter directory name to create for logs: " DIR_NAME
read -p "Enter filename to store process list (e.g., processes.txt): " FILE_NAME
```
- `read -p` prompts the user with an informative string and pauses execution until input is entered and confirmed with Enter.

### 5. Filesystem Resource Creation (`mkdir` & `touch`)
```bash
mkdir -p "$DIR_NAME"
touch "$TARGET_FILE"
```
- `mkdir -p` ensures parent directories are created safely if needed without erroring if the directory already exists.
- `touch` establishes the empty log file or updates its timestamp.

### 6. Output Redirection (`>`)
```bash
ps aux > "$TARGET_FILE"
```
- Standard output (`stdout`) of the `ps aux` command is redirected using `>` into `$TARGET_FILE`.
- Any previous content in the destination file is replaced with the fresh process snapshot.

---

## How to Run the Script

1. Navigate to the `shell-scripting` folder:
   ```bash
   cd shell-scripting
   ```

2. Ensure executable permissions are set:
   ```bash
   chmod +x system_info.sh
   ```

3. Execute the script:
   ```bash
   ./system_info.sh
   ```

4. When prompted, specify the desired directory and file name:
   ```text
   Enter directory name to create for logs: process_logs
   Enter filename to store process list (e.g., processes.txt): running_processes.txt
   ```

---

## Sample Execution Output

```text
==================================================
          SYSTEM INFORMATION DASHBOARD            
==================================================

[+] Basic Information:
--------------------------------------------------
Current Date & Time : Thu Sep  3 21:52:44 IST 2026
Host Name           : MDs-MacBook-Air.local
Logged-in Username  : mdkaif

[+] Filesystem Disk Usage (df -h):
--------------------------------------------------
Filesystem      Size   Used  Avail Capacity iused      ifree %iused  Mounted on
/dev/disk3s1s1 228Gi   11Gi   16Gi    40%  451k       171M    0%   /
/dev/disk3s5   228Gi  189Gi   16Gi    93%  1.9M       171M    1%   /System/Volumes/Data

[+] Top Running Processes (ps aux):
--------------------------------------------------
USER               PID  %CPU %MEM      VSZ    RSS   TT  STAT STARTED      TIME COMMAND
root             11431  41.5  0.4 435340960  34032   ??  Ss    9:52PM   0:00.24 XprotectService
mdkaif            8895  40.8  7.2 1894288416 604896  ??  R     4:23PM   5:24.75 Antigravity IDE Helper
_windowserver      401  24.6  0.6 436889936  48272   ??  Ss   11:41AM  52:14.68 WindowServer -daemon

==================================================
          LOG DIRECTORY & FILE CREATION           
==================================================
Enter directory name to create for logs: process_logs
Enter filename to store process list (e.g., processes.txt): running_processes.txt

[+] Creating directory: process_logs
[+] Creating file using touch: process_logs/running_processes.txt
[+] Writing running processes to process_logs/running_processes.txt using > output redirection...

==================================================
                   VERIFICATION                   
==================================================
Directory created: drwxr-xr-x  3 mdkaif  staff  96 Sep  3 21:52 process_logs
File created     : -rw-r--r--  1 mdkaif  staff  110K Sep  3 21:52 process_logs/running_processes.txt
Total lines saved: 434 processes logged

Preview of the created file (first 5 lines):
--------------------------------------------------
USER               PID  %CPU %MEM      VSZ    RSS   TT  STAT STARTED      TIME COMMAND
root             11431  49.3  0.4 435340960  34032   ??  Ss    9:52PM   0:00.24 XprotectService
mdkaif            8895  48.8  7.1 1894288416 594496  ??  R     4:23PM   5:25.31 Antigravity IDE Helper
_windowserver      401  24.5  0.6 436884576  48272   ??  Ss   11:41AM  52:14.70 WindowServer -daemon
--------------------------------------------------
Script executed successfully!
==================================================
```

---

## Practical Evidence & Screenshots

### Screenshot 1: Script Execution & Interactive Input
Execution of `system_info.sh` displaying basic info, disk usage, running processes, and user interaction.

![Script Execution](screenshots/script_execution.png)

---

### Screenshot 2: Output Redirection Verification
Inspection of the newly created directory, the generated text file, line count, and file content preview.

![Output Verification](screenshots/output_verification.png)

---

## Key Learnings

1. **Automation Efficiency:** Combining system inspection utilities into a single script saves manual effort and eliminates repetitive command typing.
2. **Interactive Shells with `read`:** The `read -p` command enables dynamic scripts that prompt administrators for directory paths and target filenames rather than hardcoding values.
3. **Data Redirection (`>`):** Output redirection decouples data production (`ps`) from persistence, directing stdout directly to disk files for permanent logging and audit trails.
4. **Resilient Scripting:** Checking and defaulting empty variables prevents unexpected runtime errors if a user presses Enter without typing a value.

---

*Maintained by mdkaif — DevOps Homework Submission*
