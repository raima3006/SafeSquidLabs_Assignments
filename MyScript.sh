#!/bin/bash

# Function to display usage information
function usage() {
    echo "Usage: $0 [-cpu] [-network] [-disk] [-load] [-memory] [-process] [-service] [-all]"
    exit 1
}

# Function to display the top 10 most used applications by CPU and memory
function display_cpu_memory() {
    echo "Top 10 Most Used Applications (CPU and Memory):"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 11
    echo ""
}

# Function to display network monitoring information
function display_network() {
    echo "Network Monitoring:"
    echo "Number of concurrent connections to the server:"
    ss -s | grep -i "estab" | awk '{print $2 " established connections"}'
    
    echo "Packet Drops:"
    netstat -s | grep -i "packet loss"
    
    echo "Network I/O (MB in/out):"
    ifconfig | awk '/RX packets/ {print $5/1048576 " MB received"} /TX packets/ {print $5/1048576 " MB transmitted"}'
    echo ""
}

# Function to display disk usage information
function display_disk_usage() {
    echo "Disk Usage:"
    df -h | awk '$5 > 80 {print $0}'
    echo ""
}

# Function to display system load information
function display_system_load() {
    echo "System Load:"
    uptime
    echo "CPU Usage Breakdown (user, system, idle, etc.):"
    mpstat | awk '/all/ {print "User: "$3"% System: "$5"% Idle: "$13"%"}'
    echo ""
}

# Function to display memory usage information
function display_memory_usage() {
    echo "Memory Usage:"
    free -m
    echo "Swap Memory Usage:"
    vmstat -s | grep "swap"
    echo ""
}

# Function to display process monitoring information
function display_process_monitoring() {
    echo "Process Monitoring:"
    echo "Number of active processes:"
    ps aux | wc -l
    echo "Top 5 Processes by CPU and Memory Usage:"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6
    echo ""
}

# Function to monitor essential services
function display_service_monitoring() {
    echo "Service Monitoring:"
    for service in sshd nginx iptables; do
        systemctl is-active --quiet $service && echo "$service is running" || echo "$service is not running"
    done
    echo ""
}

# Main logic to handle command-line switches
if [ $# -eq 0 ]; then
    usage
fi

while [ "$1" != "" ]; do
    case $1 in
        -cpu)
            display_cpu_memory
            ;;
        -network)
            display_network
            ;;
        -disk)
            display_disk_usage
            ;;
        -load)
            display_system_load
            ;;
        -memory)
            display_memory_usage
            ;;
        -process)
            display_process_monitoring
            ;;
        -service)
            display_service_monitoring
            ;;
        -all)
            display_cpu_memory
            display_network
            display_disk_usage
            display_system_load
            display_memory_usage
            display_process_monitoring
            display_service_monitoring
            ;;
        *)
            usage
            ;;
    esac
    shift
done
