#!/bin/bash

#========================================#
#     Sijcon Recon Tool by Arafat Sijan  #
#========================================#

# Color Codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to sanitize URLs for filenames
sanitize_url() {
  echo "$1" | sed 's/https\?:\/\///g' | sed 's/\//_/g' | sed 's/[?=&]/_/g'
}

# Tool checker
check_tool() {
  if ! command -v "$1" &>/dev/null; then
    echo -e "${RED}[!] $1 is not installed. Please install it.${NC}"
    exit 1
  fi
}

# Ensure required tools are present
check_tool subfinder
check_tool httpx
check_tool nuclei
check_tool python3
check_tool pip3
check_tool git

# Clone dirsearch if not available
if [ ! -d "$HOME/tools/dirsearch" ]; then
  echo -e "${YELLOW}[*] Cloning Dirsearch...${NC}"
  mkdir -p "$HOME/tools"
  git clone https://github.com/maurosoria/dirsearch.git "$HOME/tools/dirsearch"
  python3 -m pip install -r "$HOME/tools/dirsearch/requirements.txt"
fi

# Prompt for URL
read -p "Enter the URL to scan (e.g., https://example.com): " url
if [ -z "$url" ]; then
  echo -e "${RED}[!] URL cannot be empty.${NC}"
  exit 1
fi

# Extract domain
domain=$(echo "$url" | awk -F/ '{print $3}')
if [ -z "$domain" ]; then
  echo -e "${RED}[!] Unable to extract domain.${NC}"
  exit 1
fi

# Set up paths
recon_folder="$HOME/Desktop/recon"
domain_folder="$recon_folder/$domain"
timestamp=$(date +"%Y%m%d_%H%M%S")
output_dir="$domain_folder/$timestamp"
vuln_folder="$domain_folder/vuln"
dirsearch_folder="$domain_folder/dirsearch"

mkdir -p "$output_dir" "$vuln_folder" "$dirsearch_folder"
echo -e "${GREEN}[*] Results will be saved in: $output_dir${NC}"

# Ask for wordlist
read -p "Enter wordlist path (or press Enter for default): " wordlist
if [ -z "$wordlist" ]; then
  seclists_path="$HOME/tools/SecLists"
  if [ ! -d "$seclists_path" ]; then
    echo -e "${YELLOW}[*] Cloning SecLists...${NC}"
    git clone https://github.com/danielmiessler/SecLists.git "$seclists_path"
  fi
  wordlist="$seclists_path/Discovery/Web-Content/common.txt"
fi

# Run Subfinder
echo -e "${YELLOW}[*] Running Subfinder...${NC}"
subfinder -d "$domain" -silent -o "$output_dir/subdomains.txt"

# Run HTTPX
echo -e "${YELLOW}[*] Checking live hosts with HTTPX...${NC}"
httpx -l "$output_dir/subdomains.txt" -silent -o "$output_dir/live.txt"

# Create target list
cat "$output_dir/live.txt" > "$output_dir/scan_targets.txt"
echo "$url" >> "$output_dir/scan_targets.txt"
sort -u "$output_dir/scan_targets.txt" -o "$output_dir/scan_targets.txt"

# Run Nuclei
echo -e "${YELLOW}[*] Running Nuclei scans on all targets...${NC}"
nuclei -l "$output_dir/scan_targets.txt" -silent -o "$output_dir/nuclei.txt"

# Parse Nuclei output
declare -A vuln_types=(
  ["sqli"]="sql injection"
  ["xss"]="xss cross-site"
  ["csrf"]="csrf"
  ["lfi"]="lfi local file inclusion"
  ["rfi"]="rfi remote file inclusion"
  ["ssrf"]="ssrf server-side request forgery"
  ["open-redirect"]="open redirect"
)

for type in "${!vuln_types[@]}"; do
  for keyword in ${vuln_types[$type]}; do
    grep -i "$keyword" "$output_dir/nuclei.txt" | awk '{print $NF}' >> "$vuln_folder/$type.txt"
  done
  [ -f "$vuln_folder/$type.txt" ] && sort -u "$vuln_folder/$type.txt" -o "$vuln_folder/$type.txt"
done

# Run Dirsearch
sanitized_url=$(sanitize_url "$url")
echo -e "${YELLOW}[*] Running Dirsearch on $url...${NC}"
python3 "$HOME/tools/dirsearch/dirsearch.py" -u "$url" -w "$wordlist" -t 50 -o "$dirsearch_folder/$sanitized_url.txt"

echo -e "${GREEN}[*] Reconnaissance completed. Results are in $output_dir and $vuln_folder${NC}"
