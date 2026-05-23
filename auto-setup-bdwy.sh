#!/usr/bin/env bash

{
set -Eeuo pipefail

# --- CONFIGURATION ---
INSTALL_PATH="/usr/local/bin/container-updater"
CRON_PATH="/etc/cron.weekly/container-updater"
GITHUB_RAW_URL="https://raw.githubusercontent.com/unknown6003/bdwy-server-init/refs/heads/main/auto-setup-bdwy.sh"

# --- TUI ENGINE ---
FG_CYN="\e[38;5;117m"
FG_GRN="\e[38;5;115m"
FG_YLW="\e[38;5;221m"
FG_RED="\e[38;5;204m"
RST="\e[0m"

update_status() {
    # Move cursor up 1 line and clear it only when terminal control is available.
    if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
        tput cuu1 || true
        tput el || true
    fi
    echo -e "  ${FG_CYN}${RST}${FG_CYN}STATUS${RST}${FG_CYN}${RST} $1"
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo -e "\n${FG_RED}Missing required command: $1${RST}"
        exit 1
    }
}

# --- RUNTIME LAYER ---
# We use 'tee' to show progress in the TUI while logging to file for debugging
exec_live() {
    local log_file="/tmp/updater_last.log"
    echo -e "  ${FG_YLW}${RST}${FG_YLW}PROC${RST}${FG_YLW}${RST} Running: $1"
    
    if ! bash -c "$1" > "$log_file" 2>&1; then
        echo -e "\n${FG_RED}!!! ERROR DETECTED !!!${RST}"
        tail -n 20 "$log_file"
        exit 1
    fi
}

dedupe_sources_file() {
    local file="$1"
    local tmp
    tmp="$(mktemp)"

    awk '
        BEGIN {
            p = ""
        }
        {
            line = $0
            sub(/[[:space:]]+$/, "", line)
            if (line == "") {
                if (p != "") {
                    if (!seen[p]++) {
                        print p
                        print ""
                    }
                    p = ""
                }
            } else {
                if (p == "") p = line
                else p = p "\n" line
            }
        }
        END {
            if (p != "" && !seen[p]++) print p
        }
    ' "$file" > "$tmp"

    if ! cmp -s "$file" "$tmp"; then
        cp "$file" "${file}.bak.$(date +%s)"
        mv "$tmp" "$file"
        return 0
    fi

    rm -f "$tmp"
    return 1
}

dedupe_list_file() {
    local file="$1"
    local tmp
    tmp="$(mktemp)"

    awk '
        /^[[:space:]]*$/ || /^[[:space:]]*#/ {
            print
            next
        }
        {
            line = $0
            sub(/[[:space:]]+$/, "", line)
            if (!seen[line]++) print line
        }
    ' "$file" > "$tmp"

    if ! cmp -s "$file" "$tmp"; then
        cp "$file" "${file}.bak.$(date +%s)"
        mv "$tmp" "$file"
        return 0
    fi

    rm -f "$tmp"
    return 1
}

normalize_apt_sources() {
    local changes=0
    local f

    shopt -s nullglob

    for f in /etc/apt/sources.list.d/*.sources; do
        if dedupe_sources_file "$f"; then
            changes=$((changes + 1))
        fi
    done

    for f in /etc/apt/sources.list /etc/apt/sources.list.d/*.list; do
        if [ -f "$f" ] && dedupe_list_file "$f"; then
            changes=$((changes + 1))
        fi
    done

    shopt -u nullglob
    if [ "$changes" -gt 0 ]; then
        echo "Normalized $changes APT source file(s)."
    fi
    return 0
}

# --- MAIN EXECUTION ---
if [ -t 1 ]; then
    clear
fi
echo -e "${FG_CYN}┌────────────────────────────────────────────────────────┐${RST}"
echo -e "${FG_CYN}│${RST} BDWY SYSTEM INITIALIZATION ENGINE                   ${FG_CYN}│${RST}"
echo -e "${FG_CYN}└────────────────────────────────────────────────────────┘${RST}"

# 1. Setup
echo -e "  ${FG_GRN}${RST}${FG_GRN}INIT${RST}${FG_GRN}${RST} Anchoring system binaries..."
require_cmd apt-get
require_cmd awk
require_cmd mktemp
mkdir -p /usr/local/bin /etc/cron.weekly
curl -fsSL "$GITHUB_RAW_URL" -o "$INSTALL_PATH" 2>/dev/null || true
chmod +x "$INSTALL_PATH"

# 2. Target Resolution
targets=("pve-host-node")
if command -v pct >/dev/null 2>&1; then
    while read -r vmid; do targets+=("$vmid"); done < <(pct list | awk 'NR>1 {print $1}')
fi

# 3. Processing Loop
for target in "${targets[@]}"; do
    echo -e "\n${FG_YLW}>> Target: $target${RST}"
    
    # Source normalization to prevent duplicate repository entries.
    echo -e "  ${FG_CYN}${RST}${FG_CYN}APT${RST}${FG_CYN}${RST} Normalizing APT source definitions..."
    if [ "$target" == "pve-host-node" ]; then
        exec_live "normalize_apt_sources"
    fi
    update_status "${FG_GRN}✓ APT Sources Normalized${RST}"

    # Update Repos
    echo -e "  ${FG_CYN}${RST}${FG_CYN}REPO${RST}${FG_CYN}${RST} Syncing repositories..."
    if [ "$target" == "pve-host-node" ]; then
        # Force IPv4 and short timeout for speed
        exec_live "apt-get update -o Acquire::ForceIPv4=true -o Acquire::http::Timeout=5"
    else
        exec_live "pct exec $target -- apt-get update -o Acquire::ForceIPv4=true -o Acquire::http::Timeout=5"
    fi
    update_status "${FG_GRN}✓ Repository Synced${RST}"

    # Upgrade
    echo -e "  ${FG_CYN}${RST}${FG_CYN}UPGR${RST}${FG_CYN}${RST} Upgrading packages..."
    if [ "$target" == "pve-host-node" ]; then
        exec_live "apt-get dist-upgrade -y -o Dpkg::Options::=--force-confold"
    else
        exec_live "pct exec $target -- apt-get dist-upgrade -y -o Dpkg::Options::=--force-confold"
    fi
    update_status "${FG_GRN}✓ System Upgraded${RST}"

    # Cleanup
    echo -e "  ${FG_CYN}${RST}${FG_CYN}WASH${RST}${FG_CYN}${RST} Cleaning up space..."
    if [ "$target" == "pve-host-node" ]; then
        exec_live "apt-get autoremove -y && apt-get clean"
    else
        exec_live "pct exec $target -- bash -lc 'apt-get autoremove -y && apt-get clean'"
    fi
    update_status "${FG_GRN}✓ Disk Space Reclaimed${RST}"
done

echo -e "\n${FG_GRN}⚡ Optimization Complete.${RST}"
}
