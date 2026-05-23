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

exec_live_fn() {
    local fn_name="$1"
    local log_file="/tmp/updater_last.log"
    echo -e "  ${FG_YLW}${RST}${FG_YLW}PROC${RST}${FG_YLW}${RST} Running: $fn_name"

    if ! "$fn_name" > "$log_file" 2>&1; then
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

disable_enterprise_deb822_entries() {
    local f="$1"
    local tmp
    tmp="$(mktemp)"

    awk '
        BEGIN { RS=""; ORS="\n\n" }
        {
            rec = $0
            if (rec ~ /URIs:[[:space:]]*https?:\/\/enterprise\.proxmox\.com/) {
                gsub(/\nEnabled:[[:space:]]*yes/, "\nEnabled: no", rec)
                if (rec !~ /\nEnabled:[[:space:]]*(yes|no)/) {
                    rec = rec "\nEnabled: no"
                }
            }
            print rec
        }
    ' "$f" > "$tmp"

    if ! cmp -s "$f" "$tmp"; then
        cp "$f" "${f}.bak.$(date +%s)"
        mv "$tmp" "$f"
        return 0
    fi

    rm -f "$tmp"
    return 1
}

enforce_proxmox_repo_policy() {
    local codename
    codename="$(. /etc/os-release && echo "${VERSION_CODENAME:-}")"
    if [ -z "$codename" ]; then
        codename="trixie"
    fi

    mkdir -p /etc/apt/sources.list.d

    # Remove known conflicting Proxmox/Ceph source files first.
    rm -f \
        /etc/apt/sources.list.d/proxmox.sources \
        /etc/apt/sources.list.d/ceph.sources \
        /etc/apt/sources.list.d/pve-install-repo.sources \
        /etc/apt/sources.list.d/pve-install-repo.list \
        /etc/apt/sources.list.d/pve-enterprise.list \
        /etc/apt/sources.list.d/pve-enterprise.sources \
        /etc/apt/sources.list.d/ceph-enterprise.list \
        /etc/apt/sources.list.d/ceph-enterprise.sources

    # Canonical no-subscription repositories in one-line format.
    cat > /etc/apt/sources.list.d/pve-no-subscription.list <<EOF
deb http://download.proxmox.com/debian/pve ${codename} pve-no-subscription
EOF

    cat > /etc/apt/sources.list.d/ceph-no-subscription.list <<EOF
deb http://download.proxmox.com/debian/ceph-squid ${codename} no-subscription
EOF

    # Strip Proxmox/Ceph lines from /etc/apt/sources.list to avoid duplicate targets.
    if [ -f /etc/apt/sources.list ]; then
        local tmp
        tmp="$(mktemp)"
        awk '
            $0 ~ /proxmox\.com\/debian\/pve/ { next }
            $0 ~ /proxmox\.com\/debian\/ceph-/ { next }
            { print }
        ' /etc/apt/sources.list > "$tmp"
        if ! cmp -s /etc/apt/sources.list "$tmp"; then
            cp /etc/apt/sources.list "/etc/apt/sources.list.bak.$(date +%s)"
            mv "$tmp" /etc/apt/sources.list
        else
            rm -f "$tmp"
        fi
    fi

    # Disable enterprise sources if present.
    shopt -s nullglob
    local f
    for f in /etc/apt/sources.list.d/*.sources; do
        disable_enterprise_deb822_entries "$f" || true
    done
    shopt -u nullglob
}

detect_container_pkg_manager() {
    local ctid="$1"
    pct exec "$ctid" -- sh -lc '
        if command -v apt-get >/dev/null 2>&1; then echo apt; exit 0; fi
        if command -v apk >/dev/null 2>&1; then echo apk; exit 0; fi
        if command -v dnf >/dev/null 2>&1; then echo dnf; exit 0; fi
        if command -v yum >/dev/null 2>&1; then echo yum; exit 0; fi
        if command -v pacman >/dev/null 2>&1; then echo pacman; exit 0; fi
        if command -v zypper >/dev/null 2>&1; then echo zypper; exit 0; fi
        echo unknown
    '
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
        exec_live_fn enforce_proxmox_repo_policy
        exec_live_fn normalize_apt_sources
    fi
    update_status "${FG_GRN}✓ APT Sources Normalized${RST}"

    # Update Repos
    echo -e "  ${FG_CYN}${RST}${FG_CYN}REPO${RST}${FG_CYN}${RST} Syncing repositories..."
    if [ "$target" == "pve-host-node" ]; then
        # Force IPv4 and short timeout for speed
        exec_live "apt-get update -o Acquire::ForceIPv4=true -o Acquire::http::Timeout=5"
    else
        pkg_mgr="$(detect_container_pkg_manager "$target")"
        case "$pkg_mgr" in
            apt)
                exec_live "pct exec $target -- apt-get update -o Acquire::ForceIPv4=true -o Acquire::http::Timeout=5"
                ;;
            apk)
                exec_live "pct exec $target -- apk update"
                ;;
            dnf)
                exec_live "pct exec $target -- dnf -y makecache"
                ;;
            yum)
                exec_live "pct exec $target -- yum makecache -y"
                ;;
            pacman)
                exec_live "pct exec $target -- pacman -Sy --noconfirm"
                ;;
            zypper)
                exec_live "pct exec $target -- zypper --non-interactive refresh"
                ;;
            *)
                update_status "${FG_YLW}⚠ Unsupported package manager in CT ${target}; skipping${RST}"
                continue
                ;;
        esac
    fi
    update_status "${FG_GRN}✓ Repository Synced${RST}"

    # Upgrade
    echo -e "  ${FG_CYN}${RST}${FG_CYN}UPGR${RST}${FG_CYN}${RST} Upgrading packages..."
    if [ "$target" == "pve-host-node" ]; then
        exec_live "apt-get dist-upgrade -y -o Dpkg::Options::=--force-confold"
    else
        case "$pkg_mgr" in
            apt)
                exec_live "pct exec $target -- apt-get dist-upgrade -y -o Dpkg::Options::=--force-confold"
                ;;
            apk)
                exec_live "pct exec $target -- apk upgrade --no-cache"
                ;;
            dnf)
                exec_live "pct exec $target -- dnf -y upgrade --refresh"
                ;;
            yum)
                exec_live "pct exec $target -- yum -y update"
                ;;
            pacman)
                exec_live "pct exec $target -- pacman -Syu --noconfirm"
                ;;
            zypper)
                exec_live "pct exec $target -- zypper --non-interactive update"
                ;;
        esac
    fi
    update_status "${FG_GRN}✓ System Upgraded${RST}"

    # Cleanup
    echo -e "  ${FG_CYN}${RST}${FG_CYN}WASH${RST}${FG_CYN}${RST} Cleaning up space..."
    if [ "$target" == "pve-host-node" ]; then
        exec_live "apt-get autoremove -y && apt-get clean"
    else
        case "$pkg_mgr" in
            apt)
                exec_live "pct exec $target -- sh -lc 'apt-get autoremove -y && apt-get clean'"
                ;;
            apk)
                exec_live "pct exec $target -- sh -lc 'apk cache clean || rm -rf /var/cache/apk/*'"
                ;;
            dnf)
                exec_live "pct exec $target -- dnf -y autoremove"
                exec_live "pct exec $target -- dnf clean all"
                ;;
            yum)
                exec_live "pct exec $target -- yum -y autoremove || true"
                exec_live "pct exec $target -- yum clean all"
                ;;
            pacman)
                exec_live "pct exec $target -- sh -lc 'pacman -Scc --noconfirm || true'"
                ;;
            zypper)
                exec_live "pct exec $target -- zypper --non-interactive clean --all"
                ;;
        esac
    fi
    update_status "${FG_GRN}✓ Disk Space Reclaimed${RST}"
done

echo -e "\n${FG_GRN}⚡ Optimization Complete.${RST}"
}
