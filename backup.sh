#!/bin/bash

# Configuration
SOURCE_DIR="/path/to/source/directory"
REMOTE_USER="username"
REMOTE_HOST="remote.server.com"
REMOTE_DIR="/path/to/remote/directory"
LOG_FILE="/var/log/backup.log"
REPORT_FILE="/var/log/backup_report.log"

# Create log and report files if they don't exist
touch $LOG_FILE
touch $REPORT_FILE

# Function to log messages
log_message() {
    local message="$1"
    local log_level="$2"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - ${log_level} - ${message}" >> ${LOG_FILE}
    echo "$(date +'%Y-%m-%d %H:%M:%S') - ${log_level} - ${message}" >> ${REPORT_FILE}
}

# Function to perform backup
perform_backup() {
    rsync -avz --delete ${SOURCE_DIR} ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR} >> ${LOG_FILE} 2>&1
    if [[ $? -eq 0 ]]; then
        log_message "Backup successful." "INFO"
    else
        log_message "Backup failed." "ERROR"
    fi
}

# Function to send report
send_report() {
    local subject="Backup Report - $(date +'%Y-%m-%d %H:%M:%S')"
    local recipient="your_email@example.com"
    mail -s "${subject}" ${recipient} < ${REPORT_FILE}
}

# Main function
main() {
    log_message "Starting backup operation..." "INFO"
    perform_backup
    log_message "Backup operation completed." "INFO"
    send_report
    # Clear the report file for next use
    > ${REPORT_FILE}
}

# Run the main function
main
