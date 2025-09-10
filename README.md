# 🚀✨🎯 ReconStack 🎯✨🚀

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/<your-repo>/reconstack)](https://github.com/<your-repo>/reconstack/releases)
[![Issues](https://img.shields.io/github/issues/<your-repo>/reconstack)](https://github.com/<your-repo>/reconstack/issues)

**ReconStack** (`reconstack.sh`) is a 🐺 **bug bounty & pentest automation tool** for subdomain enumeration, HTTP probing, and vulnerability scanning — all in one fun and efficient workflow 🚀💻💥.

---

## ✨ Features 🌟

- 🔍 **Automated Recon Pipeline**  
  - Subdomain discovery via [Subfinder](https://github.com/projectdiscovery/subfinder) 🕵️‍♂️  
  - Alive host detection via [Httpx](https://github.com/projectdiscovery/httpx) 🌊⚡  
  - Vulnerability scanning via [Nuclei](https://github.com/projectdiscovery/nuclei) 💥🔥  

- ⚡ **Parallel-Safe Temp Files**  
  - Each domain gets a unique temp file (`subs-<domain>-$$.tmp`) 🗂️💾  

- 📝 **Background Execution & Logging**  
  - Live output + logs saved in `~/reconstack-logs/` 📂🖥️🕒  
  - Timestamped logs for easy reference 🗓️📝  

- 🎨 **Real-Time Colorized Output**  
  - Critical 🔴, High 🟣, Medium 🟡, Low 🔵 vulnerabilities  
  - Random emojis 🎉🔥💫🚀 keep the output lively  

- 🗂 **Auto Template Detection**  
  - Detects Nuclei templates automatically from common paths 🛠️📂  

- 🛑 **Kill Switch**  
  - Stop all running ReconStack jobs with `--kill` ❌💀  

- 👤 **Authors & Version**  
  - Version: `1.0.0` 🏷️  
  - Authors: 🐺 w0lfsn1p3r & 🤖 ChatGPT (GPT-5) 👨‍💻  

---

## 📥 Installation 🛠️

```bash
git clone https://github.com/Official-BlackHat13/reconstack.git
cd reconstack
chmod +x reconstack.sh
