#!/bin/bash
# ~/reconstack.sh
# ReconStack: subfinder → httpx → nuclei
# Safe background execution + real-time results + kill switch
#
# 📌 Authors:
#   🐺 w0lfsn1p3r  (Original idea & user)
#   🤖 ChatGPT (GPT-5) (Code implementation & improvements)
#
# 🚀 Version: 1.0.0

# === NEW: IGNORE CTRL+C (GLOBAL) ===
trap "" SIGINT

set -euo pipefail

TOOL_NAME="ReconStack"
TOOL_VERSION="1.0.0"
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

# Spinner emojis (100)
SPINNER_EMOJIS=( "🎉" "🔥" "🌟" "💫" "🚀" "⚡" "💥" "🌈" "🛡️" "🎯"
                 "💣" "🌊" "☀️" "💧" "🌙" "⭐" "🕹️" "🎮" "🧨" "🌪️"
                 "🌀" "🌸" "🌺" "🌻" "🍁" "🍂" "🌼" "🌷" "🌹" "🍀"
                 "🌏" "🌍" "🌎" "🌐" "🌑" "🌒" "🌓" "🌔" "🌕" "🌖"
                 "🌗" "🌘" "🌙" "☁️" "⛅" "🌤️" "🌥️" "🌦️" "🌧️" "⛈️"
                 "🌩️" "🌨️" "❄️" "☃️" "⛄" "💨" "💧" "💦" "🌊" "🔥"
                 "💡" "🔦" "🔋" "🪐" "🌌" "🌠" "🌟" "✨" "⚡" "☄️"
                 "🪄" "🎇" "🎆" "🧨" "🎃" "🎄" "🎁" "🎈" "🎉" "🎊"
                 "🏆" "🥇" "🥈" "🥉" "🏅" "🎖️" "🏵️" "🎗️" "💎" "💍"
                 "🪙" "💰" "🪜" "🛠️" "⚙️" "🔧" "🔨" "🪓" "⛏️" "🛡️" )

LOG_DIR="$HOME/reconstack-logs"
mkdir -p "$LOG_DIR"

# === ASCII Banner ===
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

# === Domain Validator ===
validate_domain() {
    [[ "$1" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}

# === Auto-detect Nuclei Templates ===
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

# === Help & Version ===
show_version() { echo "$TOOL_NAME v$TOOL_VERSION (Authors: $TOOL_AUTHOR)"; }
show_help() {
cat << EOF
$TOOL_NAME - Minimal Automated Recon Stack
Usage:
  $0 <domain>
  $0 -d domain.com
  $0 -l domains.txt
  $0 --kill
  $0 --help
  $0 --version
EOF
}

# === Kill Switch ===
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

# === Spinner ===
spinner() {
    local pid=$1 delay=0.1 idx=0 count=${#SPINNER_EMOJIS[@]}
    while kill -0 "$pid" 2>/dev/null; do
        printf " [%s]  " "${SPINNER_EMOJIS[$idx]}"
        idx=$(( (idx + 1) % count ))
        sleep $delay
        printf "\b\b\b\b\b\b\b"
    done
}

# === Nuclei Colorizer ===
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

# === Execute with Spinner ===
run_command_with_spinner() {
    local cmd=("$@")
    "${cmd[@]}" & local pid=$!
    spinner $pid
    wait $pid
}

# === Main Recon Function ===
run_recon() {
    local DOMAIN=$1
    local TMPFILE="subs-${DOMAIN}-$$.tmp"

    echo -e "${GREEN}[+] $(shuf -n1 -e "${EMO_RECON_START[@]}") Starting recon for $DOMAIN${RESET}"

    echo -e "${YELLOW}[*] $(shuf -n1 -e "${EMO_SUBFINDER[@]}") Finding subdomains...${RESET}"
    run_command_with_spinner subfinder -d "$DOMAIN" -silent -o "$TMPFILE"

    echo -e "${YELLOW}[*] $(shuf -n1 -e "${EMO_HTTPX[@]}") Probing alive hosts...${RESET}"
    run_command_with_spinner bash -c "httpx -l $TMPFILE -o '${DOMAIN}.txt'"

    echo -e "${YELLOW}[*] $(shuf -n1 -e "${EMO_NUCLEI[@]}") Running nuclei scans...${RESET}"
    nuclei -l "${DOMAIN}.txt" -t "$NUCLEI_TEMPLATES" \
        | tee >(colorize_nuclei) | tee "${DOMAIN}.nuclei.txt"

    rm -f "$TMPFILE"
    echo -e "${GREEN}[+] $(shuf -n1 -e "${EMO_SUCCESS[@]}") Recon finished for $DOMAIN${RESET}\n"
}

# === Interactive Mode ===
if [[ $# -eq 0 ]]; then
    ascii_banner
    echo -ne "${CYAN}🔎 Enter domain to scan: ${RESET}"
    read DOMAIN
    validate_domain "$DOMAIN" || { echo -e "${RED}❌ Invalid domain!${RESET}"; exit 1; }
    echo -e "${GREEN}✅ Valid domain: $DOMAIN${RESET}"
    run_recon "$DOMAIN"
    exit 0
fi

# === -d example.com ===
if [[ $# -eq 2 && "$1" == "-d" ]]; then
    DOMAIN="$2"
    validate_domain "$DOMAIN" || { echo -e "${RED}❌ Invalid domain!${RESET}"; exit 1; }
    echo -e "${GREEN}✅ Valid domain: $DOMAIN${RESET}"
    run_recon "$DOMAIN"
    exit 0
fi

# === Background Launch ===
if [[ -z "${RECON_BG_RUNNING:-}" ]]; then
    export RECON_BG_RUNNING=1
    LOG_FILE="$LOG_DIR/recon-$(date +%F_%H-%M).log"
    ascii_banner
    echo -e "${GREEN}[+] 🎯 Running in background. Logs: $LOG_FILE${RESET}"
    setsid bash -c "$0 $* | tee -a '$LOG_FILE'" &
    disown
    exit 0
fi

# === FINAL (original untouched block) ===
trap "" SIGINT
if [ $# -eq 1 ]; then
    run_recon "$1"
elif [ $# -eq 2 ] && [ "$1" == "-l" ]; then
    while read -r domain; do
        [[ -z "$domain" ]] && continue
        run_recon "$domain"
    done < "$2"
else
    show_help
    exit 1
fi