# SqlServer.BruteForcePack

If you are running Microsoft SQL Server you probably aware of brute-force attacks. Almost every SQL server connected to the Internet is under constant attack. Once a hacker has access to a SA (DBA) account, or even a normal user account, it can get full access to the file system on a server, or even to the files on the network to which it is connected.

This pack of scripts made with SQL Server Stored Procedures and PowerShell Scripts, helps identify and block these attacks on your SQL Server.

### Installation
Its really simple to install de pack, just follow these steps:
 1. Clone or Download the Repository
 2. Execute all SQL Server SCRIPTS in the ***Scripts***  directory.
 3. Configure the Connection String for your server in the ** *Configs.psd1 * ** file.
 4. Try out!
 
### Configuration
** Configs.ps1 ** holds all pack configuration and tweaks:
** ConnString ** = SQL Server Connection String  
** MaxFailedLogins  ** =  Number of Failed Logins that will be considered as attack 

# Functions and Utilities
**.\IdentifyBruteForceIPs.ps1**
Identifies the IPs that are performing attacks at the last hour.

**.\CompareBruteForceIPs.ps1**
On first run the script will only collect the list of IPs that are performing attacks on the server. In the next runs the previous collection will be compared and the script will compare to find out if any ip had a higher or lower attack rate in the last hour.

**.\BlockBruteForceIPs.ps1**
MUST run on SQL Server Machine as it will create rules on port 1433 to automatically block access to IPs that are identified as malicious. 
This script can  be scheduled and run multiple times , but running at short intervals can cause high resource consumption on the SQL Server server.

