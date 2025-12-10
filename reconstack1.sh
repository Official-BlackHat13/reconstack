#!/bin/bash
# ~/reconstack.sh
# ReconStack: subfinder → httpx → nuclei
# Background execution + live logging + kill switch + interactive + colorized output
#
# 📌 Authors:
#   🐺 w0lfsn1p3r  (Original idea & user)
#   🤖 ChatGPT (GPT-5) (Code implementation & improvements)
#
# 🚀 Version: 1.1.0

set -euo pipefail
trap "" SIGINT  # Ignore Ctrl+C globally

TOOL_NAME="ReconStack"
TOOL_VERSION="1.1.0"
TOOL_AUTHOR="🐺 w0lfsn1p3r & 🤖 ChatGPT (GPT-5)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Emojis per process
EMO_RECON_START=("🎯" "🛡️" "🌟" "🚀" "💫")
EMO_SUBFINDER=("🔍" "👀" "📡" "🕵️‍♂️" "🗂️")
EMO_HTTPX=("🌊" "⚡" "☀️" "🔥" "💧")
EMO_NUCLEI=("💥" "💢" "🔥" "⚠️" "🔎")
EMO_SUCCESS=("✅" "🎉" "💯" "🏆" "🌈")

# Spinner emojis
SPINNER_EMOJIS=( "🎉" "🔥" "🌟" "💫" "🚀" "⚡" "💥" "🌈" "🛡️" "🎯" )

# Log directory
LOG_DIR="$HOME/reconstack-logs"
mkdir -p "$LOG_DIR"

# ASCII Banner
ascii_banner() {
cat << "EOF"
 ███████████                                          █████████   █████                       █████     
░░███░░░░░███                                        ███░░░░░███ ░░███                       ░░███      
 ░███    ░███   ██████   ██████   ██████  ████████  ░███    ░░░  ███████    ██████    ██████  ░███ █████
 ░██████████   ███░░███ ███░░███ ███░░███░░███░░███ ░░█████████ ░░░███░    ░░░░░███  ███░░███ ░███░░███ 
 ░███░░░░░███ ░███████ ░███ ░░░ ░███ ░███ ░███ ░███  ░░░░░░░░███  ░███      ███████ ░███ ░░░  ░██████░  
 ░███    ░███ ░███░░░  ░███  ███░███ ░███ ░███ ░███  ███    ░███  ░███ ███ ███░░███ ░███  ███ ░███░░███ 
 █████   █████░░██████ ░░██████ ░░██████  ████ █████░░█████████   ░░█████ ░░████████░░██████  ████ █████
░░░░░   ░░░░░  ░░░░░░   ░░░░░░   ░░░░░░  ░░░░ ░░░░░  ░░░░░░░░░     ░░░░░   ░░░░░░░░  ░░░░░░  ░░░░ ░░░░░ 
EOF
echo -e "                     ${GREEN}🚀 $TOOL_NAME v$TOOL_VERSION — Subfinder → Httpx → Nuclei 🚀${RESET}"
echo -e "                     ${CYAN}👤 Authors: $TOOL_AUTHOR${RESET}\n"
}

# Domain validator
validate_domain() {
    [[ "$1" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}

# Auto-detect nuclei templates
NUCLEI_TEMPLATES=""
POSSIBLE_TEMPLATE_DIRS=(
    "$HOME/nuclei-templates"
    "$HOME/.local/nuclei-templates"
    "$HOME/.nuclei-templates"
    "/root/nuclei-templates"
    "/opt/nuclei-templates"
    "/usr/local/share/nuclei-templates"
)
for dir in "${POSSIBLE_TEMPLATE_DIRS[@]}"; do
    [[ -d "$dir" ]] && NUCLEI_TEMPLATES="$dir" && break
done
[[ -z "$NUCLEI_TEMPLATES" ]] && echo -e "${RED}[!] No nuclei templates found!${RESET}" && exit 1

# Help & version
show_version() { echo "$TOOL_NAME v$TOOL_VERSION (Authors: $TOOL_AUTHOR)"; }
show_help() {
cat << EOF
$TOOL_NAME - Automated Recon Stack
Usage:
  $0 <domain>
  $0 -d domain.com
  $0 -l domains.txt
  $0 --kill
  $0 --help
  $0 --version
EOF
}

# Kill switch
if [[ $# -eq 1 && "$1" == "--kill" ]]; then
    echo -e "${RED}[!] Stopping all ReconStack processes...${RESET}"
    pkill -f "reconstack.sh" 2>/dev/null || true
    pkill -f "subfinder" 2>/dev/null || true
    pkill -f "httpx" 2>/dev/null || true
    pkill -f "nuclei" 2>/dev/null || true
    echo -e "${GREEN}[+] All processes stopped.${RESET}"
    exit 0
fi

[[ $# -eq 1 && "$1" == "--help" ]] && { ascii_banner; show_help; exit 0; }
[[ $# -eq 1 && "$1" == "--version" ]] && { show_version; exit 0; }

# Spinner function
spinner() {
    local pid=$1 delay=0.1 idx=0 count=${#SPINNER_EMOJIS[@]}
    while kill -0 "$pid" 2>/dev/null; do
        printf " [%s]  " "${SPINNER_EMOJIS[$idx]}"
        idx=$(( (idx + 1) % count ))
        sleep $delay
        printf "\b\b\b\b\b\b\b"
    done
}

# Colorize nuclei output
colorize_nuclei() {
    while IFS= read -r line; do
        if [[ "$line" =~ Critical ]]; then
            echo -e "${RED}$(shuf -n1 -e "${EMO_NUCLEI[@]}") $line${RESET}"
        elif [[ "$line" =~ High ]]; then
            echo -e "${MAGENTA}$(shuf -n1 -e "${EMO_NUCLEI[@]}") $line${RESET}"
        elif [[ "$line" =~ Medium ]]; then
            echo -e "${YELLOW}$(shuf -n1 -e "${EMO_NUCLEI[@]}") $line${RESET}"
        else
            echo -e "$(shuf -n1 -e "${EMO_NUCLEI[@]}") $line"
        fi
    done
}

# Run command with spinner
run_command_with_spinner() {
    local cmd=("$@")
    "${cmd[@]}" & local pid=$!
    spinner $pid
    wait $pid
}

# Main recon function
run_recon() {
    local DOMAIN=$1
    local TMPFILE="$LOG_DIR/subs-${DOMAIN}-$$.tmp"

    echo -e "${GREEN}[+] $(shuf -n1 -e "${EMO_RECON_START[@]}") Starting recon for $DOMAIN${RESET}"

    echo -e "${YELLOW}[*] $(shuf -n1 -e "${EMO_SUBFINDER[@]}") Finding subdomains...${RESET}"
    run_command_with_spinner subfinder -d "$DOMAIN" -silent -o "$TMPFILE"

    echo -e "${YELLOW}[*] $(shuf -n1 -e "${EMO_HTTPX[@]}") Probing alive hosts...${RESET}"
    run_command_with_spinner bash -c "httpx -l $TMPFILE -o '$LOG_DIR/${DOMAIN}.txt' -no-resume"

    echo -e "${YELLOW}[*] $(shuf -n1 -e "${EMO_NUCLEI[@]}") Running nuclei scans...${RESET}"
    nuclei -l "$LOG_DIR/${DOMAIN}.txt" -t "$NUCLEI_TEMPLATES" -no-resume \
        | tee >(colorize_nuclei) | tee "$LOG_DIR/${DOMAIN}.nuclei.txt"

    rm -f "$TMPFILE"
    echo -e "${GREEN}[+] $(shuf -n1 -e "${EMO_SUCCESS[@]}") Recon finished for $DOMAIN${RESET}\n"
}

# === Interactive input ===
if [[ $# -eq 0 ]]; then
    ascii_banner
    echo -ne "${CYAN}🔎 Enter domain to scan: ${RESET}"
    read DOMAIN
    validate_domain "$DOMAIN" || { echo -e "${RED}❌ Invalid domain!${RESET}"; exit 1; }
    echo -e "${GREEN}✅ Valid domain: $DOMAIN${RESET}"
fi

# === Background launch + logging ===
if [[ -z "${RECON_BG_RUNNING:-}" ]]; then
    export RECON_BG_RUNNING=1
    LOG_FILE="$LOG_DIR/recon-$(date +%F_%H-%M).log"
    ascii_banner
    echo -e "${GREEN}[+] 🎯 Running in background. Logs: $LOG_FILE${RESET}"
    setsid bash -c "$0 $* | tee -a '$LOG_FILE'" &
    disown
    exit 0
fi

# === Run recon ===
if [[ -n "${DOMAIN:-}" ]]; then
    run_recon "$DOMAIN"
elif [[ $# -eq 2 && "$1" == "-d" ]]; then
    DOMAIN="$2"
    validate_domain "$DOMAIN" || { echo -e "${RED}❌ Invalid domain!${RESET}"; exit 1; }
    run_recon "$DOMAIN"
elif [[ $# -eq 2 && "$1" == "-l" ]]; then
    while read -r domain; do
        [[ -z "$domain" ]] && continue
        run_recon "$domain"
    done < "$2"
else
    show_help
    exit 1
fi