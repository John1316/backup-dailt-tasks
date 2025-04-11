#!/bin/bash
# ===== CHANGE THESE SETTINGS =====
# The folder you want to back up
FOLDER_TO_BACKUP="/var/www"

# Where to save your backups
BACKUP_LOCATION="/home/$USER/Backups"

# Where to save log files
LOG_LOCATION="/home/$USER/Backups/logs"

# How many days of backups to keep
DAYS_TO_KEEP=7

# How many log files to keep
LOGS_TO_KEEP=5
# ================================

# Create a timestamp for this backup
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Create the log file name
mkdir -p "$LOG_LOCATION"
LOG_FILE="$LOG_LOCATION/backup_$TIMESTAMP.log"

# Start logging
echo "EASY BACKUP ===>>"
echo "Today's date: $(date) Going to back up: $FOLDER_TO_BACKUP Saving to: $BACKUP_LOCATION Logging to: $LOG_FILE"

# First, make sure the backup folder exists
echo "step 1 Creating backup folder if needed ===>>"
mkdir -p "$BACKUP_LOCATION"
echo "✓ Done"

# Check if the folder to backup exists
echo "step 2 Checking if the folder to backup exists ===>>"
if [ ! -d "$FOLDER_TO_BACKUP" ]; then
    echo "ERROR: Cannot find $FOLDER_TO_BACKUP Please edit this script and change FOLDER_TO_BACKUP to a folder that exists."
    exit 1
fi
echo "✓ Folder exists"

# Create a filename with today's date
TODAY=$(date +"%Y-%m-%d")
BACKUP_FILE="$BACKUP_LOCATION/backup_$TODAY.tar.gz"

# Create the backup
echo "step 3 Creating backup ===>>"
if tar -czf "$BACKUP_FILE" "$FOLDER_TO_BACKUP" 2>> "$LOG_FILE"; then
    echo "✓ Backup created successfully! Your backup is saved at: $BACKUP_FILE"
else
    echo "Try checking if you have permission to read $FOLDER_TO_BACKUP and write to $BACKUP_LOCATION Check the log file for details: $LOG_FILE"
    exit 1
fi

# Remove old backups
echo "step Removing backups older than $DAYS_TO_KEEP days ===>>"
find "$BACKUP_LOCATION" -name "backup_*.tar.gz" -type f -mtime +$DAYS_TO_KEEP -delete -print | while read -r deleted_file; do
    echo "Deleted old backup: $deleted_file"
done
echo "✓ Old backups cleaned up"

# Rotate logs (keep only the most recent logs)
echo "step 5 Rotating logs (keeping last $LOGS_TO_KEEP) ===>>"
# Count how many log files we have
LOG_COUNT=$(find "$LOG_LOCATION" -name "backup_*.log" | wc -l)
if [ "$LOG_COUNT" -gt "$LOGS_TO_KEEP" ]; then
    # If we have more logs than we want to keep, delete the oldest ones
    LOGS_TO_DELETE=$((LOG_COUNT - LOGS_TO_KEEP))
    # Find the oldest logs and delete them
    find "$LOG_LOCATION" -name "backup_*.log" -type f | sort | head -n "$LOGS_TO_DELETE" | while read -r old_log; do
        rm "$old_log"
        echo "  Deleted old log: $(basename "$old_log")"
    done
fi  
echo "✓ Log rotation complete ===>>"
echo "Log file saved at: $LOG_FILE To restore files from this backup, use: tar -xzf $BACKUP_FILE -C /folder/to/extract/to"