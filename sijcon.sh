#!/bin/bash

# Color definitions for terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to sanitize URL for file names
sanitize_url() {
  echo "$1" | sed 's/https\?:\/\///g' | sed 's/\//_/g' | sed 's/[?=&]/_/g'
}

# Check if required tools are installed
check_tool() {
  if ! command -v "$1" &> /dev/null; then
    echo -e "${RED}[!] $1 is not installed. Please install it first.${NC}"
    exit 1
  fi
}

# Verify required tools
check_tool subfinder
check_tool httpx
check_tool nuclei
if [ ! -d "$HOME/tools/dirsearch" ]; then
  echo -e "${YELLOW}[*] Cloning Dirsearch...${NC}"
  mkdir -p "$HOME/tools"
  git clone https://github.com/maurosoria/dirsearch.git "$HOME/tools/dirsearch"
  pip3 install -r "$HOME/tools/dirsearch/requirements.txt"
fi

# Prompt for URL
read -p "Enter the URL to scan (e.g., https://example.com): " url
if [ -z "$url" ]; then
  echo -e "${RED}[!] URL cannot be empty!${NC}"
  exit 1
fi

# Extract domain from URL
domain=$(echo "$url" | awk -F/ '{print $3}')
if [ -z "$domain" ]; then
  echo -e "${RED}[!] Could not extract domain from URL!${NC}"
  exit 1
fi

# Set up folder paths
recon_folder="$HOME/Desktop/recon"
domain_folder="$recon_folder/$domain"
vuln_folder="$domain_folder/vuln"
dirsearch_folder="$domain_folder/dirsearch"
timestamp=$(date +"%Y%m%d_%H%M%S")
output_dir="$domain_folder/$timestamp"

# Create folders
mkdir -p "$output_dir"
mkdir -p "$vuln_folder"
mkdir -p "$dirsearch_folder"
echo -e "${GREEN}[*] Results will be saved in: $output_dir${NC}"

# Prompt for wordlist
read -p "Enter wordlist path (or press Enter for default): " wordlist
if [ -z "$wordlist" ]; then
  seclists_path="$HOME/tools/Seclists"
  if [ ! -d "$seclists_path" ]; then
    echo -e "${YELLOW}[*] Cloning SecLists...${NC}"
    mkdir -p "$HOME/tools"
    git clone https://github.com/danielmiessler/SecLists.git "$seclists_path"
  fi
  wordlist="$seclists_path/Discovery/Web-Content/common.txt"
fi

# Subdomain enumeration
echo -e "${YELLOW}[*] Running Subfinder...${NC}"
subfinder -d "$domain" -silent -o "$output_dir/subdomains.txt"

# Check live hosts
echo -e "${YELLOW}[*] Checking live hosts with HTTPX...${NC}"
httpx -l "$output_dir/subdomains.txt" -silent -o "$output_dir/live.txt"

# Create scan targets list
cat "$output_dir/live.txt" > "$output_dir/scan_targets.txt"
echo "$url" >> "$output_dir/scan_targets.txt"
sort -u "$output_dir/scan_targets.txt" -o "$output_dir/scan_targets.txt"

# Run Nuclei for vulnerability scanning
echo -e "${YELLOW}[*] Running Nuclei scans on all targets...${NC}"
nuclei -l "$output_dir/scan_targets.txt" -silent -o "$output_dir/nuclei.txt"

# Define vulnerability types and keywords
declare -A vuln_types
vuln_types["sqli"]="sql injection"
vuln_types["xss"]="xss cross-site"
vuln_types["csrf"]="csrf"
vuln_types["lfi"]="lfi local file inclusion"
vuln_types["rfi"]="rfi remote file inclusion"
vuln_types["ssrf"]="ssrf server-side request forgery"
vuln_types["open-redirect"]="open redirect"

# Parse Nuclei output for vulnerabilities
for type in "${!vuln_types[@]}"; do
  keywords="${vuln_types[$type]}"
  IFS=' ' read -r -a keyword_array <<< "$keywords"
  for keyword in "${keyword_array[@]}"; do
    grep -i "$keyword" "$output_dir/nuclei.txt" | awk '{print $NF}' >> "$vuln_folder/$type.txt"
  done
  if [ -f "$vuln_folder/$type.txt" ]; then
    sort -u "$vuln_folder/$type.txt" -o "$vuln_folder/$type.txt"
  fi
done

# Run Dirsearch on the specific URL
sanitized_url=$(sanitize_url "$url")
echo -e "${YELLOW}[*] Running Dirsearch on $url...${NC}"
python3 "$HOME/tools/dirsearch/dirsearch.py" -u "$url" -w "$wordlist" -t 50 -o "$dirsearch_folder/$sanitized_url.txt"

echo -e "${GREEN}[*] Reconnaissance completed. Results are in $output_dir and $vuln_folder${NC}"
