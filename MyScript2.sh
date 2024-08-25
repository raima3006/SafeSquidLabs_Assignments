#!/bin/bash

# Configuration Variables
REPORT="/var/log/security_audit_report.txt"
ALERT_EMAIL="admin@example.com"

# Helper Functions
log() {
    echo -e "[`date`] - $1" | tee -a $REPORT
}

send_alert() {
    if [ -n "$ALERT_EMAIL" ]; then
        mail -s "Critical Security Alert" $ALERT_EMAIL < $REPORT
    fi
}

# 1. User and Group Audits
user_group_audit() {
    log "User and Group Audit:"
    log "List of all users and groups:"
    getent passwd | cut -d: -f1 | tee -a $REPORT
    getent group | cut -d: -f1 | tee -a $REPORT

    log "Users with UID 0 (root privileges):"
    awk -F: '($3 == "0") {print}' /etc/passwd | tee -a $REPORT

    log "Users without passwords or with weak passwords:"
    awk -F: '($2 == "" || $2 == "!") {print $1 " has no password set"}' /etc/shadow | tee -a $REPORT
    echo ""
}

# 2. File and Directory Permissions
file_permission_audit() {
    log "File and Directory Permissions Audit:"
    log "World-writable files and directories:"
    find / -xdev -type d -perm -0002 | tee -a $REPORT
    find / -xdev -type f -perm -0002 | tee -a $REPORT

    log "SUID/SGID files:"
    find / -xdev \( -perm -4000 -o -perm -2000 \) -type f | tee -a $REPORT

    log "Checking SSH directory permissions:"
    if [ -d /etc/ssh ]; then
        find /etc/ssh -type f -exec stat -c "%a %n" {} \; | tee -a $REPORT
    fi
    echo ""
}

# 3. Service Audits
service_audit() {
    log "Service Audit:"
    log "Listing all running services:"
    systemctl list-units --type=service --state=running | tee -a $REPORT

    log "Critical service status check:"
    for service in sshd iptables; do
        systemctl is-active --quiet $service && log "$service is running" || log "$service is not running"
    done
    echo ""
}

# 4. Firewall and Network Security
firewall_audit() {
    log "Firewall and Network Security Audit:"
    log "Checking if firewall is active:"
    if command -v ufw &> /dev/null; then
        ufw status | tee -a $REPORT
    elif command -v iptables &> /dev/null; then
        iptables -L | tee -a $REPORT
    else
        log "No firewall detected!"
    fi

    log "Checking for open ports:"
    ss -tuln | tee -a $REPORT

    log "Checking IP forwarding settings:"
    sysctl net.ipv4.ip_forward | tee -a $REPORT
    sysctl net.ipv6.conf.all.forwarding | tee -a $REPORT
    echo ""
}

# 5. IP and Network Configuration Checks
ip_network_audit() {
    log "IP and Network Configuration Audit:"
    log "Public vs. Private IP Checks:"
    for ip in $(hostname -I); do
        if [[ $ip =~ ^10\.|^172\.(1[6-9]|2[0-9]|3[01])\.|^192\.168\. ]]; then
            log "$ip is a private IP address."
        else
            log "$ip is a public IP address."
        fi
    done
    echo ""
}

# 6. Security Updates and Patching
security_updates_audit() {
    log "Security Updates and Patching:"
    log "Checking for available security updates:"
    if command -v apt-get &> /dev/null; then
        apt-get update -y && apt-get upgrade -y | tee -a $REPORT
    elif command -v yum &> /dev/null; then
        yum update -y | tee -a $REPORT
    fi
    echo ""
}

# 7. Log Monitoring
log_monitoring() {
    log "Log Monitoring:"
    log "Checking for recent suspicious SSH login attempts:"
    grep "Failed password" /var/log/auth.log | tail -n 10 | tee -a $REPORT
    echo ""
}

# 8. Server Hardening Steps
server_hardening() {
    log "Server Hardening Steps:"

    log "SSH Configuration Hardening:"
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl reload sshd

    log "Disabling IPv6:"
    sysctl -w net.ipv6.conf.all.disable_ipv6=1
    sysctl -w net.ipv6.conf.default.disable_ipv6=1
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf

    log "Securing the GRUB bootloader:"
    grub-mkpasswd-pbkdf2 | tee -a $REPORT
    echo -e "GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"" >> /etc/default/grub
    update-grub

    log "Firewall Configuration:"
    if command -v ufw &> /dev/null; then
        ufw allow ssh
        ufw enable
    elif command -v iptables &> /dev/null; then
        iptables -A INPUT -i lo -j ACCEPT
        iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        iptables -A INPUT -p tcp --dport 22 -j ACCEPT
        iptables -P INPUT DROP
        iptables -P FORWARD DROP
        iptables -P OUTPUT ACCEPT
    fi

    log "Configuring Automatic Security Updates:"
    if command -v unattended-upgrades &> /dev/null; then
        dpkg-reconfigure -plow unattended-upgrades
    elif command -v yum-cron &> /dev/null; then
        systemctl enable yum-cron && systemctl start yum-cron
    fi
    echo ""
}

# 9. Custom Security Checks
custom_security_checks() {
    log "Custom Security Checks:"
    if [ -f custom_checks.sh ]; then
        bash custom_checks.sh | tee -a $REPORT
    else
        log "No custom security checks found."
    fi
    echo ""
}

# 10. Reporting and Alerting
reporting_and_alerting() {
    log "Generating Final Report and Sending Alerts (if any):"
    if grep -q "No firewall detected!" $REPORT; then
        send_alert
    fi
}

# Main Execution Block
log "Starting Security Audit and Hardening Process"
user_group_audit
file_permission_audit
service_audit
firewall_audit
ip_network_audit
security_updates_audit
log_monitoring
server_hardening
custom_security_checks
reporting_and_alerting
log "Security Audit and Hardening Process Completed"

