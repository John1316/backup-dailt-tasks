#!/bin/bash
# Change this to the location of your backup script
BACKUP_SCRIPT="/home/john/Desktop/backup-task.bash"

# Make the backup script executable
chmod +x "$BACKUP_SCRIPT"

# Add the cron job to run at 2:00 AM daily
(crontab -l 2>/dev/null || echo "") | grep -v "$BACKUP_SCRIPT" | echo "0 2 * * * $BACKUP_SCRIPT" | crontab -

echo "Done! Your backup will run automatically at 2:00 AM every day."
echo "To see your scheduled tasks, type: crontab -l"