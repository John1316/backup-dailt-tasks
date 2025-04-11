# Automatic Backup System

This package contains two scripts that work together to create an automated backup system:

1. **Scheduler Script** - Sets up a daily cron job to run your backup automatically
2. **Backup Script** - Performs the actual backup operation

## Installation

1. Save both scripts to your preferred location (e.g., `/home/username/Desktop/`)
2. Make both scripts executable:
   ```
   chmod +x cron-job.bash
   chmod +x backup-task.bash
   ```

## Configuration

### Backup Script (system_daily.bash)

Edit the following settings at the top of the backup script:

```bash
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
```

### Scheduler Script

If needed, edit the path to your backup script:

```bash
BACKUP_SCRIPT="/home/john/Desktop/backup-task.bash"
```

## Usage

### Setting Up the Automatic Schedule

Run the scheduler script to set up the cron job:

```
./cron-job.bash
```

This will schedule your backup script to run daily at 2:00 AM.

### Running a Manual Backup

You can also run the backup script manually at any time:

```
./backup-task.bash
```

### Checking Your Scheduled Tasks

To verify that your cron job has been set up correctly:

```
crontab -l
```

You should see a line like:
```
0 2 * * * /home/john/Desktop/backup-task.bash
```

## Testing

### Testing Basic Functionality

1. Run the backup script manually:
   ```
   ./backup-task.bash
   ```
   
2. Check that a backup file was created in your `BACKUP_LOCATION` directory.
   
3. Verify that a log file was created in your `LOG_LOCATION` directory.

### Testing Error Handling

To test how the script handles errors:

1. Temporarily change `FOLDER_TO_BACKUP` to a non-existent directory.
   
2. Run the script and verify that it exits with an error message.
   
3. Change it back to a valid directory when done testing.

### Testing Backup Retention

To test the cleanup of old backups:

1. Temporarily set `DAYS_TO_KEEP` to 0.
   
2. Create a test backup by running the script.
   
3. Run the script again and verify that the previous backup was deleted.
   
4. Reset `DAYS_TO_KEEP` to your preferred value when done.

## Restoring from Backup

To restore files from a backup:

```
tar -xzf /path/to/backup_file.tar.gz -C /folder/to/extract/to
```

For example:

```
tar -xzf /home/username/Backups/backup_2025-04-11.tar.gz -C /tmp/restore
```

## Troubleshooting

- **Script doesn't run automatically**: Check your cron job with `crontab -l` and ensure the path is correct.
  
- **Permission denied errors**: Ensure both scripts are executable (`chmod +x`) and that your user has permission to read the backup source and write to the backup destination.
  
- **Missing backups**: Check the log files in your `LOG_LOCATION` for any error messages.

## Known Issues

- The cron scheduler script may have a syntax error in the crontab entry: `0 2 * ** $BACKUP_SCRIPT` should be `0 2 * * * $BACKUP_SCRIPT` (the day of week field has an extra asterisk).