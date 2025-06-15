
                          Sijcon Recon Tool (sijcon.sh)
                          
===========================================================================

The **Sijcon Recon Tool** (sijcon.sh) is an automated Bash script designed for 
cybersecurity professionals to perform comprehensive reconnaissance on a target 
URL. It automates subdomain enumeration, live host verification, vulnerability 
scanning, and directory enumeration, organizing the results in a structured 
folder hierarchy on your desktop. This tool is ideal for penetration testing, 
bug bounty hunting, and security assessments.

- Author: Arafat Rahman Sijan
- Version: 1.0.0
- Last Updated: June 15, 2025
- Repository: https://github.com/ar-sijan-official/sijcon-recon-tool

--------------------------------------------------------------------------------
                                System Requirements
--------------------------------------------------------------------------------

- Operating System: Kali Linux (recommended)
- Dependencies:
  - git (for cloning the repository)
  - go (for installing Subfinder, HTTPX, and Nuclei)
  - python3 and pip3 (for Dirsearch)
  - Internet connection (for downloading tools and scanning)
- Installed Tools: Subfinder, HTTPX, Nuclei, and Dirsearch (installed automatically 
  by the script if missing)

--------------------------------------------------------------------------------
                                  Installation
--------------------------------------------------------------------------------

### Step 1: Clone the Repository
1. Open a terminal on your Kali Linux system.
2. Clone the repository:
   $ git clone https://github.com/ar-sijan-official/sijcon-recon-tool.git ~/sijcon-recon-tool
   $ cd ~/sijcon-recon-tool

### Step 2: Install Dependencies
1. Install Go tools:
   $ sudo apt update
   $ sudo apt install golang
   $ go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
   $ go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
   $ go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
2. Verify installations:
   $ subfinder -version
   $ httpx -version
   $ nuclei -version
   *The script will handle Dirsearch and SecLists installation if not present.*

### Step 3: Make the Script Executable
1. Set executable permissions:
   $ chmod +x ~/sijcon-recon-tool/sijcon.sh

### Step 4: (Optional) Move to System Path
1. For global access, move the script:
   $ sudo mv ~/sijcon-recon-tool/sijcon.sh /usr/local/bin/sijcon
   $ sudo chmod +x /usr/local/bin/sijcon
2. Test by running 'sijcon' from any directory.

--------------------------------------------------------------------------------
                                    Usage
--------------------------------------------------------------------------------

### Running the Script
- From Repository Directory:
  1. Navigate to the cloned directory:
     $ cd ~/sijcon-recon-tool
     $ ./sijcon.sh
- From System Path (if moved):
  1. Simply run:
     $ sijcon

### Interactive Prompts
The script will prompt you for input:
- URL: Enter the target URL (e.g., https://example.com).
  - Example: https://example.com/login
- Wordlist: Optionally enter a custom wordlist path (e.g., /path/to/wordlist.txt) 
  or press Enter to use the default (~/tools/Seclists/Discovery/Web-Content/common.txt).

### Example Session
$ ./sijcon.sh
Enter the URL to scan (e.g., https://example.com): https://example.com
Enter wordlist path (or press Enter for default): 
[*] Cloning SecLists...
[*] Results will be saved in: /root/Desktop/recon/example.com/20250615_231712
[*] Running Subfinder...
[*] Checking live hosts with HTTPX...
[*] Running Nuclei scans on all targets...
[*] Running Dirsearch on https://example.com...
[*] Reconnaissance completed. Results are in /root/Desktop/recon/example.com/20250615_231712 and /root/Desktop/recon/example.com/vuln

### What the Script Does
- Subdomain Enumeration: Uses Subfinder to discover subdomains of the target domain.
- Live Host Checking: Uses HTTPX to verify which subdomains are active.
- Vulnerability Scanning: Runs Nuclei to detect vulnerabilities (e.g., SQLi, XSS, CSRF).
- Directory Enumeration: Uses Dirsearch to find directories and files on the target URL.
- Data Organization: Saves results in ~/Desktop/recon/<domain>/<timestamp>/ with a vuln 
  subfolder for categorized vulnerabilities.

--------------------------------------------------------------------------------
                              Output Structure
--------------------------------------------------------------------------------
The script creates a folder hierarchy under ~/Desktop/recon/:
- <domain>/<timestamp>/
  - subdomains.txt: List of discovered subdomains.
  - live.txt: List of live hosts.
  - scan_targets.txt: Combined list of targets.
  - nuclei.txt: Raw vulnerability scan results.
- <domain>/vuln/
  - sqli.txt: URLs with SQL injection vulnerabilities.
  - xss.txt: URLs with Cross-Site Scripting vulnerabilities.
  - csrf.txt: URLs with CSRF vulnerabilities.
  - lfi.txt: URLs with Local File Inclusion vulnerabilities.
  - rfi.txt: URLs with Remote File Inclusion vulnerabilities.
  - ssrf.txt: URLs with Server-Side Request Forgery vulnerabilities.
  - open-redirect.txt: URLs with open redirect vulnerabilities.
- <domain>/dirsearch/
  - <sanitized_url>.txt: Directory enumeration results (e.g., example.com.txt).

### Example
~/Desktop/recon/example.com/20250615_231712/
  ├── subdomains.txt
  ├── live.txt
  ├── scan_targets.txt
  ├── nuclei.txt
~/Desktop/recon/example.com/vuln/
  ├── sqli.txt
  ├── xss.txt
  └── ...
~/Desktop/recon/example.com/dirsearch/
  └── example.com.txt

--------------------------------------------------------------------------------
                              Best Practices
--------------------------------------------------------------------------------
- Ethical Use: Only scan URLs you have explicit permission to test. Unauthorized 
  scanning may violate laws or terms of service.
- Custom Wordlists: Use a specific wordlist (e.g., from SecLists or custom 
  collections) for deeper directory enumeration.
- Performance: Run on a stable internet connection; large scans may take time.
- Review Results: Check vuln/*.txt files for critical findings and validate with 
  manual testing.

--------------------------------------------------------------------------------
                              Troubleshooting
--------------------------------------------------------------------------------
- Tool Not Found: Install missing tools (e.g., subfinder) with the Go commands 
  above or let the script handle it.
- Empty Output: Ensure the URL is valid and accessible. Check internet connectivity.
- Permission Denied: Run with sudo if ~/Desktop/recon cannot be created, or adjust 
  folder permissions.
- Dirsearch Errors: Verify Python 3 and pip3 are installed (sudo apt install 
  python3-pip if needed).

--------------------------------------------------------------------------------
                               Contributing
--------------------------------------------------------------------------------
- Report issues or suggest features on the [GitHub Issues page]
  (https://github.com/ar-sijan-official/sijcon-recon-tool/issues).
- Submit pull requests with improvements (e.g., additional tools or parsing logic).

--------------------------------------------------------------------------------
                                  License
--------------------------------------------------------------------------------
This tool is released under the MIT License. See the LICENSE file for details.

--------------------------------------------------------------------------------
                                  Contact
--------------------------------------------------------------------------------
- Author: Arafat Rahman Sijan
- Email: ar.sijan.official@gmail.com
- Portfolio: https://ar-sijan-official.github.io/arsijan
================================================================================
