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

# === Auto-detect Nuclei Templates ===
NUCLEI_TEMPLATES=""
if [[ -n "${NUCLEI_TEMPLATES:-}" && -d "$NUCLEI_TEMPLATES" ]]; then
    :
else
    POSSIBLE_TEMPLATE_DIRS=(
        "$HOME/nuclei-templates"
        "$HOME/.local/nuclei-templates"
        "$HOME/.nuclei-templates"
        "/root/nuclei-templates"
        "/root/.local/nuclei-templates"
        "/opt/nuclei-templates"
        "/usr/local/share/nuclei-templates"
    )
    for dir in "${POSSIBLE_TEMPLATE_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            NUCLEI_TEMPLATES="$dir"
            break
        fi
    done
    if [[ -z "$NUCLEI_TEMPLATES" ]]; then
        echo -e "${RED}[!] No nuclei templates directory found.${RESET}"
        echo "    Set manually: export NUCLEI_TEMPLATES=/path/to/templates"
        exit 1
    fi
fi

# === Help & Version ===
show_version() { echo "$TOOL_NAME v$TOOL_VERSION (Authors: $TOOL_AUTHOR)"; }
show_help() {
cat << EOF
$TOOL_NAME - Minimal Automated Recon Stack

Usage:
  $0 <domain>          Run recon for a single domain
  $0 -l domains.txt    Run recon for multiple domains (line-separated)
  $0 --help            Show this help menu
  $0 --version         Show version
  $0 --kill            Kill all running $TOOL_NAME jobs (subfinder, httpx, nuclei)

Logs saved in: $LOG_DIR
EOF
}

# === Kill Switch ===
if [[ $# -eq 1 && "$1" == "--kill" ]]; then
    echo -e "${RED}[!] Stopping all running $TOOL_NAME processes...${RESET}"
    pkill -f "reconstack.sh" 2>/dev/null || true
    pkill -f "subfinder" 2>/dev/null || true
    pkill -f "httpx" 2>/dev/null || true
    pkill -f "nuclei" 2>/dev/null || true
    echo -e "${GREEN}[+] All $TOOL_NAME jobs have been terminated.${RESET}"
    exit 0
fi

[[ $# -eq 1 && "$1" == "--help" ]] && { ascii_banner; show_help; exit 0; }
[[ $# -eq 1 && "$1" == "--version" ]] && { show_version; exit 0; }

# === Spinner Function ===
spinner() {
    local pid=$1 delay=0.1 idx=0 count=${#SPINNER_EMOJIS[@]}
    while kill -0 "$pid" 2>/dev/null; do
        printf " [%s]  " "${SPINNER_EMOJIS[$idx]}"
        idx=$(( (idx + 1) % count ))
        sleep $delay
        printf "\b\b\b\b\b\b\b"
    done
}

# === Colorize Nuclei Output ===
colorize_nuclei() {
    while IFS= read -r line; do
        if [[ "$line" =~ Critical ]]; then
            echo -e "${RED}$(shuf -n1 -e "${EMO_NUCLEI[@]}") $line${RESET}"
        elif [[ "$line" =~ High ]]; then
            echo -e "${MAGENTA}$(shuf -n1 -e "${EMO_NUCLEI[@]}") $line${RESET}"
        elif [[ "$line" =~ Medium ]]; then
            echo -e "${YELLOW}$(shuf -n1 -e "${EMO_NUCLEI[@]}") $line${RESET}"
        elif [[ "$line" =~ Low ]]; then
            echo -e "${CYAN}$(shuf -n1 -e "${EMO_NUCLEI[@]}") $line${RESET}"
        else
            echo -e "$(shuf -n1 -e "${EMO_NUCLEI[@]}") $line"
        fi
    done
}

# === Run Command with Spinner ===
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
    nuclei -l "${DOMAIN}.txt" -t "$NUCLEI_TEMPLATES" | tee >(colorize_nuclei) | tee "${DOMAIN}.nuclei.txt"

    rm -f "$TMPFILE"
    echo -e "${GREEN}[+] $(shuf -n1 -e "${EMO_SUCCESS[@]}") Recon finished for $DOMAIN${RESET}\n"
}

# === Background Launch with Live Output ===
if [[ -z "${RECON_BG_RUNNING:-}" ]]; then
    export RECON_BG_RUNNING=1
    LOG_FILE="$LOG_DIR/recon-$(date +%F_%H-%M).log"
    ascii_banner
    echo -e "${GREEN}[+] 🎯 Starting $TOOL_NAME in background. Logs: $LOG_FILE${RESET}"
    setsid bash -c "$0 $* | tee -a '$LOG_FILE'" &
    disown
    exit 0
fi

trap "" SIGINT

# === Input Handling ===
if [ $# -eq 1 ]; then
    run_recon "$1"
elif [ $# -eq 2 ] && [ "$1" == "-l" ]; then
    while read -r domain; do [[ -z "$domain" ]] && continue; run_recon "$domain"; done < "$2"
else
    show_help; exit 1
fi
