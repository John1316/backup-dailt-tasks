#!/bin/bash
FOLDER_TO_BACKUP="/var/www"
BACKUP_LOCATION="/home/root/Backups"
LOG_LOCATION="/home/root/Backups/logs"
DAYS_TO_KEEP=7
LOGS_TO_KEEP=5
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
EMAIL_ALERT="johnmaher179@gmail.com"  # Replace with your email address
mkdir -p "$LOG_LOCATION"
LOG_FILE="$LOG_LOCATION/backup_$TIMESTAMP.log"

log_message() {
    echo "$1"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

send_email_alert() {
    SUBJECT="$1"
    MESSAGE="$2"
    echo "$MESSAGE" | mail -s "$SUBJECT" "$EMAIL_ALERT"
}
log_message "Today's date: $(date) Going to back up: $FOLDER_TO_BACKUP Saving to: $BACKUP_LOCATION Logging to: $LOG_FILE"

# Step 1
log_message "Step 1: Creating backup folder if needed..."
mkdir -p "$BACKUP_LOCATION"
log_message "✓ Done"

# check if file exists
log_message "Step 2: Checking if the folder to backup exists..."
if [ ! -d "$FOLDER_TO_BACKUP" ]; then
    log_message "ERROR: Cannot find $FOLDER_TO_BACKUP Please edit this script and change FOLDER_TO_BACKUP to a folder that exists."
    send_email_alert "Backup Folder Creation Failed" "$ERROR_MSG\nCheck log file: $LOG_FILE"

    exit 1
fi
log_message "✓ Folder exists"

# create a file name with today
TODAY=$(date +"%Y-%m-%d")
BACKUP_FILE="$BACKUP_LOCATION/backup_$TODAY.tar.gz"

# create the backup
log_message "Step 3: Creating backup... (this might take a while)"
if tar -czf "$BACKUP_FILE" "$FOLDER_TO_BACKUP" 2>> "$LOG_FILE"; then
    SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    log_message "✓ Backup created successfully! Your backup is saved at: $BACKUP_FILE Backup size: $SIZE"
else
    log_message "ERROR: Could not create the backup. Try checking if you have permission to read $FOLDER_TO_BACKUP and write to $BACKUP_LOCATION Check the log file for details: $LOG_FILE"
    send_email_alert "Backup Creation Failed" "$ERROR_MSG\nCheck log file: $LOG_FILE"

    exit 1
fi

# Remove old backups
log_message "Step 4: Removing backups older than $DAYS_TO_KEEP days..."
find "$BACKUP_LOCATION" -name "backup_*.tar.gz" -type f -mtime +$DAYS_TO_KEEP -delete -print | while read -r deleted_file; do
    log_message "  Deleted old backup: $deleted_file"
done
log_message "✓ Old backups cleaned up"

# Rotate logs (keep only the most recent logs)
log_message "Step 5: Rotating logs (keeping last $LOGS_TO_KEEP)..."
# Count how many log files we have
LOG_COUNT=$(find "$LOG_LOCATION" -name "backup_*.log" | wc -l)
if [ "$LOG_COUNT" -gt "$LOGS_TO_KEEP" ]; then
    # If we have more logs than we want to keep, delete the oldest ones
    LOGS_TO_DELETE=$((LOG_COUNT - LOGS_TO_KEEP))
    # Find the oldest logs and delete them
    find "$LOG_LOCATION" -name "backup_*.log" -type f | sort | head -n "$LOGS_TO_DELETE" | while read -r old_log; do
        rm "$old_log"
        log_message "  Deleted old log: $(basename "$old_log")"
    done
fi

log_message "✓ Log rotation complete ===>>"
log_message "Log file saved at: $LOG_FILE To restore files from this backup, use: tar -xzf $BACKUP_FILE -C /folder/to/extract/to"