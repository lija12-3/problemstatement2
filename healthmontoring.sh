#!/bin/bash

# Log file location
LOG_FILE="/var/log/system_health.log"

# Thresholds
CPU_USAGE_THRESHOLD=80  # in percentage
MEMORY_USAGE_THRESHOLD=80  # in percentage
DISK_USAGE_THRESHOLD=80  # in percentage
RUNNING_PROCESSES_THRESHOLD=200  # maximum number of running processes

# Function to log messages
log_message() {
    local message="$1"
    local log_level="$2"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - ${log_level} - ${message}" >> ${LOG_FILE}
}

# Function to check CPU usage
check_cpu_usage() {
    local cpu_usage
    cpu_usage=$(mpstat 1 1 | awk '/Average/ {print 100 - $NF}')
    cpu_usage=${cpu_usage%.*}  # Convert to integer
    if (( cpu_usage > CPU_USAGE_THRESHOLD )); then
        log_message "High CPU usage detected: ${cpu_usage}%" "WARNING"
    else
        log_message "CPU usage is normal: ${cpu_usage}%" "INFO"
    fi
}

# Function to check memory usage
check_memory_usage() {
    local memory_usage
    memory_usage=$(free | awk '/Mem/ {print $3/$2 * 100.0}')
    memory_usage=${memory_usage%.*}  # Convert to integer
    if (( memory_usage > MEMORY_USAGE_THRESHOLD )); then
        log_message "High Memory usage detected: ${memory_usage}%" "WARNING"
    else
        log_message "Memory usage is normal: ${memory_usage}%" "INFO"
    fi
}

# Function to check disk usage
check_disk_usage() {
    local disk_usage
    disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if (( disk_usage > DISK_USAGE_THRESHOLD )); then
        log_message "High Disk usage detected: ${disk_usage}%" "WARNING"
    else
        log_message "Disk usage is normal: ${disk_usage}%" "INFO"
    fi
}

# Function to check number of running processes
check_running_processes() {
    local processes_count
    processes_count=$(ps aux | wc -l)
    if (( processes_count > RUNNING_PROCESSES_THRESHOLD )); then
        log_message "High number of running processes detected: ${processes_count}" "WARNING"
    else
        log_message "Number of running processes is normal: ${processes_count}" "INFO"
    fi
}

# Main function
main() {
    log_message "Starting system health check..." "INFO"
    check_cpu_usage
    check_memory_usage
    check_disk_usage
    check_running_processes
    log_message "System health check completed." "INFO"
}

# Run the main function
main
