###############Task 1: System Monitoring Script########################
This Bash script provides a real-time dashboard to monitor various system resources, such as CPU usage, memory usage, network activity, and disk usage. It can be customized to show specific 
parts of the dashboard using command-line switches.

Features
Top 10 Applications: Displays the top 10 CPU and memory-consuming applications.
Network Monitoring: Shows the number of concurrent connections, packet drops, and data in/out.
Disk Usage: Displays disk space usage with warnings for partitions using over 90% of the space.
System Load: Reports current load average and CPU usage breakdown.
Memory Usage: Shows total, used, and free memory along with swap memory usage.
Process Monitoring: Lists active processes and highlights the top 5 by CPU and memory usage.
Service Monitoring: Monitors the status of critical services like SSH, iptables, and web servers.

1. Run the Script: ./MyScript.sh
2. View CPU and memory usage: ./MyScript.sh -cpu
3. View network monitoring: ./MyScript.sh -network
4. View disk usage:  ./MyScript.sh -disk
5. View system load: ./MyScript.sh -load
6. View memory usage: ./MyScript.sh -memory
7. View process monitoring:  ./MyScript.sh -process
8. View service monitoring: ./MyScript.sh -services
   
To ensure the necessary permissions to execute scripts: chmod +x MyScript.sh
Example: ./MyScript.sh -cpu



############################ Task 2: Security Audit and Server Hardening Script ##############################
This Bash script automates security audits and server hardening processes for Linux servers. It checks for common vulnerabilities, performs IP and network configuration audits, and 
implements server hardening measures based on best practices.

Features
User and Group Audits: Lists all users and groups, checks for root privileges, and identifies weak passwords.
File Permissions Audit: Scans for world-writable files, SSH directory permissions, and SUID/SGID files.
Service Audits: Lists running services, ensures critical services are running, and checks for unauthorized services.
Firewall and Network Security: Verifies firewall configuration, checks open ports, and identifies IP forwarding issues.
IP and Network Configuration: Identifies public vs. private IPs and secures sensitive services.
Security Updates and Patching: Checks for and applies security updates.
Log Monitoring: Monitors logs for suspicious activities, such as failed SSH login attempts.
Server Hardening: Configures SSH, disables IPv6, secures the bootloader, and configures automatic updates.

1. Run the Script: sudo ./MyScript2.sh
2. User and Group Audit: ./MyScript2.sh -user-audit
3. File and Directory Permissions: ./MyScript2.sh -file-audit
4. Service Audit: ./MyScript2.sh -service-audit
5. Firewall Audit: ./MyScript2.sh -firewall-audit
6. IP and Network Audit: ./MyScript2.sh -network-audit
7. Security Updates: ./MyScript2.sh -update-check
8. Log Monitoring: ./MyScript2.sh -log-monitor
9. Server Hardening: ./MyScript2.sh -harden

To ensure the necessary permissions to execute scripts: chmod +x MyScript2.sh
Example: ./MyScript2.sh -cpu
