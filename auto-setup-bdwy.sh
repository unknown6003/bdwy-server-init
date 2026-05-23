#!/usr/bin/env bash

# --- MISSION CRITICAL ENCLOSURE BLOCK ---
{
set -Eeuo pipefail

# --- ENFORCE CORE SYSTEM FILEPATH LAYOUTS ---
mkdir -p /usr/local/bin /etc/cron.weekly /root/.config

# --- CONFIGURATION VARIABLES ---
INSTALL_PATH="/usr/local/bin/container-updater"
CRON_PATH="/etc/cron.weekly/container-updater"
GITHUB_RAW_URL="https://raw.githubusercontent.com/unknown6003/bdwy-server-init/refs/heads/main/auto-setup-bdwy.sh"
ERR_LOG="/tmp/updater_stderr.log"
APT_LOG="/tmp/updater_apt.log"

STARSHIP_CONFIG_CONTENT=$(cat << 'EOF'
"$schema" = 'https://starship.rs/config-schema.json'

format = """
[](red)\
$os\
$username\
[](bg:peach fg:red)\
$directory\
[](bg:yellow fg:peach)\
$git_branch\
$git_status\
[](fg:yellow bg:green)\
$c\
$rust\
$golang\
$nodejs\
$php\
$java\
$kotlin\
$haskell\
$python\
[](fg:green bg:sapphire)\
$conda\
[](fg:sapphire bg:lavender)\
$time\
[ ](fg:lavender)\
$cmd_duration\
$line_break\
$character"""

palette = 'catppuccin_mocha'

[os]
disabled = false
style = "bg:red fg:crust"

[os.symbols]
Windows = ""
Ubuntu = "󰕈"
SUSE = ""
Raspbian = "󰐿"
Mint = "󰣭"
Macos = "󰀵"
Manjaro = ""
Linux = "󰌽"
Gentoo = "󰣨"
Fedora = "󰣛"
Alpine = ""
Amazon = ""
Android = ""
Arch = "󰣇"
Artix = "󰣇"
CentOS = ""
Debian = "󰣚"
Redhat = "󱄛"
RedHatEnterprise = "󱄛"

[username]
show_always = true
style_user = "bg:red fg:crust"
style_root = "bg:red fg:crust"
format = '[ $user]($style)'

[directory]
style = "bg:peach fg:crust"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Music" = "󰝚 "
"Pictures" = " "
"Developer" = "󰲋 "

[git_branch]
symbol = ""
style = "bg:yellow"
format = '[[ $symbol $branch ](fg:crust bg:yellow)]($style)'

[git_status]
style = "bg:yellow"
format = '[[($all_status$ahead_behind )](fg:crust bg:yellow)]($style)'

[nodejs]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[c]
symbol = " "
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[rust]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[golang]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[php]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[java]
symbol = " "
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[kotlin]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[haskell]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

[python]
symbol = ""
style = "bg:green"
format = '[[ $symbol( $version)(\(#$virtualenv\)) ](fg:crust bg:green)]($style)'

[docker_context]
symbol = ""
style = "bg:sapphire"
format = '[[ $symbol( $context) ](fg:crust bg:sapphire)]($style)'

[conda]
symbol = "  "
style = "fg:crust bg:sapphire"
format = '[$symbol$environment ]($style)'
ignore_base = false

[time]
disabled = false
time_format = "%R"
style = "bg:lavender"
format = '[[  $time ](fg:crust bg:lavender)]($style)'

[line_break]
disabled = false

[character]
disabled = false
success_symbol = '[❯](bold fg:green)'
error_symbol = '[❯](bold fg:red)'
vimcmd_symbol = '[❮](bold fg:green)'
vimcmd_replace_one_symbol = '[❮](bold fg:lavender)'
vimcmd_replace_symbol = '[❮](bold fg:lavender)'
vimcmd_visual_symbol = '[❮](bold fg:yellow)'

[cmd_duration]
show_milliseconds = true
format = " in $duration "
style = "bg:lavender"
disabled = false
show_notifications = true
min_time_to_notify = 45000

[palettes.catppuccin_mocha]
rosewater = "#f5e0dc"
flamingo = "#f2cdcd"
pink = "#f5c2e7"
mauve = "#cba6f7"
red = "#f38ba8"
maroon = "#eba0ac"
peach = "#fab387"
yellow = "#f9e2af"
green = "#a6e3a1"
teal = "#94e2d5"
sky = "#89dceb"
sapphire = "#74c7ec"
blue = "#89b4fa"
lavender = "#b4befe"
text = "#cdd6f4"
subtext1 = "#bac2de"
subtext0 = "#a6adc8"
overlay2 = "#9399b2"
overlay1 = "#7f849c"
overlay0 = "#6c7086"
surface2 = "#585b70"
surface1 = "#45475a"
surface0 = "#313244"
base = "#1e1e2e"
mantle = "#181825"
crust = "#11111b"
EOF
)

# --- TUI GEOMETRIC THEME COLOR ENGINE ---
BG_RED="\e[48;5;204m\e[38;5;232m"
BG_PCH="\e[48;5;209m\e[38;5;232m"
BG_YLW="\e[48;5;221m\e[38;5;232m"
BG_GRN="\e[48;5;115m\e[38;5;232m"
BG_SAP="\e[48;5;110m\e[38;5;232m"
BG_LAV="\e[48;5;147m\e[38;5;232m"

FG_RED="\e[38;5;204m"
FG_PCH="\e[38;5;209m"
FG_YLW="\e[38;5;221m"
FG_GRN="\e[38;5;115m"
FG_SAP="\e[38;5;110m"
FG_LAV="\e[38;5;147m"
FG_MNT="\e[38;5;237m"
RST="\e[0m"

log_banner() {
    clear
    echo -e "${FG_RED}┌────────────────────────────────────────────────────────────────────────┐${RST}"
    echo -e "${FG_RED}│${RST} ${BG_RED}  SYSTEM INITIALIZATION ENGINE ${RST}                                      ${FG_RED}│${RST}"
    echo -e "${FG_RED}└────────────────────────────────────────────────────────────────────────┘${RST}"
}

log_tui_section() {
    local idx="$1" total="$2" name="$3" type="$4"
    echo -e "\n${FG_SAP}${RST}${BG_SAP} TARGET PANEL ${idx}/${total} ${RST}${FG_SAP}${RST} ${FG_LAV}ID: ${name}${RST} [Type: ${type}]"
    echo -e "${FG_MNT}────────────────────────────────────────────────────────────────────────${RST}"
}

log_tui_step() {
    local status_color="$1" tag="$2" msg="$3"
    printf "  ${status_color}${RST}${status_color}${tag}${RST}${status_color}${RST} %-50s\n" "$msg"
}

log_tui_status() {
    local color="$1" symbol="$2" text="$3"
    printf "\033[1A\033[65C[${color}${symbol}${RST}] ${color}${text}${RST}\n"
}

run_animated() {
    local log_target="$1"
    shift
    
    "$@" >> "$log_target" 2>&1 &
    local pid=$!
    
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0
    
    tput civis || true 
    
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${FG_SAP}${RST}${BG_SAP} ACTIVITY ${RST}${FG_SAP}${RST} ${FG_YLW}%s${RST} Processing in background..." "${frames[i]}"
        i=$(( (i + 1) % 10 ))
        sleep 0.1
    done
    
    tput cnorm || true
    printf "\r\033[K"  
    
    wait "$pid"
    return $?
}

# --- UNATTENDED NON-INTERACTIVE CALL CONSTANTS ---
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
export NEEDRESTART_MODE=a
export NEEDRESTART_SUSPEND=1

# Hardened APT parameters: Forces IPv4 to skip broken IPv6 DNS stalls, sets 10s cutoff for HTTP/HTTPS
APT_HEADLESS="apt-get -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold -o Acquire::Retries=3 -o Acquire::http::Timeout=10 -o Acquire::https::Timeout=10 -o Acquire::ForceIPv4=true -o Dpkg::Use-Pty=0 -y"

check_file() {
    local type="$1" target="$2" path="$3"
    if [ "$type" = "proxmox-lxc" ]; then pct exec "$target" -- [ -f "$path" ] < /dev/null; else [ -f "$path" ]; fi
}

check_binary() {
    local type="$1" target="$2" binary="$3"
    if [ "$type" = "proxmox-lxc" ]; then pct exec "$target" -- which "$binary" < /dev/null >/dev/null 2>&1; else command -v "$binary" < /dev/null >/dev/null 2>&1; fi
}

# --- MAIN EXECUTION ROUTINE ---
main() {
    > "$APT_LOG"
    > "$ERR_LOG"

    mkdir -p /usr/local/bin /etc/cron.weekly /root/.config
    
    if [ "${0##*/}" = "bash" ] || [ ! -f "$INSTALL_PATH" ]; then
        log_banner
        log_tui_step "${FG_PCH}" "INIT" "Writing core controller engine shell payload"
        
        if curl -fsSL --connect-timeout 10 "$GITHUB_RAW_URL" -o /tmp/updater-bin.tmp < /dev/null; then
            mv /tmp/updater-bin.tmp "$INSTALL_PATH"
            chmod +x "$INSTALL_PATH"
            log_tui_status "${FG_GRN}" "✓" "DONE"
            
            log_tui_step "${FG_PCH}" "CRON" "Anchoring periodic weekly execution wrappers"
            cat << EOF > "$CRON_PATH"
#!/bin/sh
curl -fsSL "$GITHUB_RAW_URL" -o "$INSTALL_PATH" && chmod +x "$INSTALL_PATH"
"$INSTALL_PATH" --cron
EOF
            chmod +x "$CRON_PATH"
            log_tui_status "${FG_GRN}" "✓" "READY"
        else
            log_tui_status "${FG_RED}" "⚠" "FALLBACK ACTIVE (LOCAL RECOVERY MODE)"
        fi
    fi

    targets=()
    target_modes=()

    if command -v pct >/dev/null 2>&1; then
        targets+=("pve-host-node")
        target_modes+=("pve-host")
        vmid_list=$(pct list | awk 'NR>1 && $2=="running" {print $1}')
        for vmid in $vmid_list; do
            targets+=("$vmid")
            target_modes+=("proxmox-lxc")
        done
    else
        targets+=("local-machine")
        target_modes+=("local")
    fi

    total_targets=${#targets[@]}

    for i in "${!targets[@]}"; do
        target="${targets[$i]}"
        mode="${target_modes[$i]}"
        idx=$((i + 1))
        
        log_tui_section "$idx" "$total_targets" "$target" "$mode"

        if [ "$mode" = "pve-host" ]; then
            os_type="debian"
        elif check_file "$mode" "$target" "/etc/alpine-release"; then
            os_type="alpine"
        elif check_file "$mode" "$target" "/etc/debian_version"; then
            os_type="debian"
        else
            log_tui_step "${FG_RED}" "WARN" "Undocumented system profile identified"
            log_tui_status "${FG_YLW}" "⚠" "SKIP"
            continue
        fi

        # 1. Package Synchronization
        log_tui_step "${FG_YLW}" "REPO" "Refreshing system package architectures"
        
        set +e 
        if [ "$mode" = "pve-host" ]; then
            killall -9 apt apt-get dpkg 2>/dev/null || true
            rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/lib/apt/lists/lock /var/cache/apt/archives/lock
            
            # Clean duplicate configurations aggressively
            rm -f /etc/apt/sources.list.d/pve-no-sub.list 2>/dev/null || true
            rm -f /etc/apt/sources.list.d/pve-enterprise.list 2>/dev/null || true
            rm -f /etc/apt/sources.list.d/ceph.list 2>/dev/null || true
            
            # Smart patch: Modify deb822 files without creating duplicates
            if [ -f /etc/apt/sources.list.d/proxmox.sources ]; then
                sed -i 's/enterprise.proxmox.com/download.proxmox.com/g' /etc/apt/sources.list.d/proxmox.sources || true
                sed -i 's/pve-enterprise/pve-no-subscription/g' /etc/apt/sources.list.d/proxmox.sources || true
            fi
            
            # Only add standard fallback if we completely lack community repos
            if ! grep -rq "pve-no-subscription" /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null; then
                OS_CODENAME=$(grep "VERSION_CODENAME" /etc/os-release | cut -d'=' -f2 || echo "bookworm")
                echo "deb http://download.proxmox.com/debian/pve $OS_CODENAME pve-no-subscription" > /etc/apt/sources.list.d/pve-no-sub.list
            fi
            
            run_animated "$ERR_LOG" sh -c "dpkg --configure -a >> '$APT_LOG' 2>&1 && $APT_HEADLESS update >> '$APT_LOG' 2>&1 && $APT_HEADLESS dist-upgrade >> '$APT_LOG' 2>&1"
            cmd_status=$?
        elif [ "$os_type" = "debian" ]; then
            if [ "$mode" = "proxmox-lxc" ]; then
                run_animated "$ERR_LOG" pct exec "$target" -- sh -c "killall -9 apt apt-get dpkg 2>/dev/null || true; rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/lib/apt/lists/lock /var/cache/apt/archives/lock; dpkg --configure -a >> '$APT_LOG' 2>&1 && export DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a NEEDRESTART_SUSPEND=1; apt-get -o Acquire::Retries=3 -o Acquire::http::Timeout=10 -o Acquire::https::Timeout=10 -o Acquire::ForceIPv4=true -y update >> '$APT_LOG' 2>&1 && apt-get -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold -y dist-upgrade >> '$APT_LOG' 2>&1" < /dev/null
            else
                killall -9 apt apt-get dpkg 2>/dev/null || true
                rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/lib/apt/lists/lock /var/cache/apt/archives/lock
                run_animated "$ERR_LOG" sh -c "dpkg --configure -a >> '$APT_LOG' 2>&1 && $APT_HEADLESS update >> '$APT_LOG' 2>&1 && $APT_HEADLESS dist-upgrade >> '$APT_LOG' 2>&1"
            fi
            cmd_status=$?
        elif [ "$os_type" = "alpine" ]; then
            if [ "$mode" = "proxmox-lxc" ]; then
                run_animated "$ERR_LOG" pct exec "$target" -- sh -c "apk update >> '$APT_LOG' 2>&1 && apk upgrade >> '$APT_LOG' 2>&1" < /dev/null
            else
                run_animated "$ERR_LOG" sh -c "apk update >> '$APT_LOG' 2>&1 && apk upgrade >> '$APT_LOG' 2>&1"
            fi
            cmd_status=$?
        fi
        set -e 

        if [ "$cmd_status" -ne 0 ]; then
            log_tui_status "${FG_RED}" "✘" "CRASHED"
            echo -e "\n${FG_RED}┌─── CRITICAL SYSTEM DIAGNOSTIC ERROR LOG ───────────────────────────────┐${RST}"
            cat "$ERR_LOG" | sed 's/^/  /' || echo "  Unknown structural system network stall."
            echo -e "${FG_RED}└────────────────────────────────────────────────────────────────────────┘${RST}"
            echo -e "${FG_YLW}Detailed full trace saved to: $APT_LOG${RST}"
            exit 1
        fi
        log_tui_status "${FG_GRN}" "✓" "UPDATED"

        # 2. Automated Deep Space Cleansing
        log_tui_step "${FG_SAP}" "WASH" "Executing orphaned package and cache destruct sequences"
        set +e
        if [ "$os_type" = "debian" ] || [ "$mode" = "pve-host" ]; then
            if [ "$mode" = "proxmox-lxc" ]; then
                run_animated "$ERR_LOG" pct exec "$target" -- sh -c "export DEBIAN_FRONTEND=noninteractive; apt-get -y autoremove --purge >> '$APT_LOG' 2>&1 && apt-get clean >> '$APT_LOG' 2>&1" < /dev/null
            else
                run_animated "$ERR_LOG" sh -c "$APT_HEADLESS autoremove --purge >> '$APT_LOG' 2>&1 && $APT_HEADLESS clean >> '$APT_LOG' 2>&1"
            fi
        elif [ "$os_type" = "alpine" ]; then
            if [ "$mode" = "proxmox-lxc" ]; then
                run_animated "$ERR_LOG" pct exec "$target" -- sh -c "apk cache clean >> '$APT_LOG' 2>&1" < /dev/null
            else
                run_animated "$ERR_LOG" sh -c "apk cache clean >> '$APT_LOG' 2>&1"
            fi
        fi
        set -e
        log_tui_status "${FG_GRN}" "✓" "CLEANED"

        # 3. Unattended Engine Setup
        log_tui_step "${FG_YLW}" "AUTO" "Injecting unattended processing background engines"
        if [ "$os_type" = "debian" ] || [ "$mode" = "pve-host" ]; then
            if [ "$mode" = "pve-host" ] || [ "$mode" = "local" ]; then
                run_animated "$ERR_LOG" sh -c "$APT_HEADLESS install unattended-upgrades apt-listchanges >> '$APT_LOG' 2>&1 && echo 'unattended-upgrades unattended-upgrades/enable_auto_updates boolean true' | debconf-set-selections >> '$APT_LOG' 2>&1 && dpkg-reconfigure -f noninteractive unattended-upgrades >> '$APT_LOG' 2>&1"
            elif [ "$mode" = "proxmox-lxc" ]; then
                run_animated "$ERR_LOG" pct exec "$target" -- sh -c "export DEBIAN_FRONTEND=noninteractive; apt-get -y install unattended-upgrades apt-listchanges >> '$APT_LOG' 2>&1 && echo 'unattended-upgrades unattended-upgrades/enable_auto_updates boolean true' | debconf-set-selections >> '$APT_LOG' 2>&1 && dpkg-reconfigure -f noninteractive unattended-upgrades >> '$APT_LOG' 2>&1" < /dev/null
            fi
        elif [ "$os_type" = "alpine" ]; then
            run_animated "$ERR_LOG" sh -c "if [ '$mode' = 'proxmox-lxc' ]; then pct exec '$target' -- sh -c 'apk add cronie && rc-update add cronie default || true && rc-service cronie start || true' >> '$APT_LOG' 2>&1; else apk add cronie && rc-update add cronie default || true && rc-service cronie start || true >> '$APT_LOG' 2>&1; fi"
            cron_script="#!/bin/sh\napk update && apk upgrade && apk cache clean"
            if [ "$mode" = "proxmox-lxc" ]; then echo -e "$cron_script" | pct exec "$target" -- tee /etc/periodic/daily/apk-upgrade > /dev/null; else echo -e "$cron_script" | tee /etc/periodic/daily/apk-upgrade > /dev/null; fi
            if [ "$mode" = "proxmox-lxc" ]; then pct exec "$target" -- chmod +x /etc/periodic/daily/apk-upgrade < /dev/null; else chmod +x /etc/periodic/daily/apk-upgrade < /dev/null; fi
        fi
        log_tui_status "${FG_GRN}" "✓" "ACTIVE"

        # 4. Starship Configs
        log_tui_step "${FG_PCH}" "SHSH" "Verifying localized Starship engine prompt presence"
        if ! check_binary "$mode" "$target" "starship"; then
            if [ "$os_type" = "debian" ]; then 
                if [ "$mode" = "proxmox-lxc" ]; then run_animated "$ERR_LOG" pct exec "$target" -- sh -c "apt-get install -y curl >> '$APT_LOG' 2>&1" < /dev/null; else run_animated "$ERR_LOG" sh -c "apt-get install -y curl >> '$APT_LOG' 2>&1"; fi
            fi
            if [ "$os_type" = "alpine" ]; then 
                if [ "$mode" = "proxmox-lxc" ]; then run_animated "$ERR_LOG" pct exec "$target" -- sh -c "apk add curl >> '$APT_LOG' 2>&1" < /dev/null; else run_animated "$ERR_LOG" sh -c "apk add curl >> '$APT_LOG' 2>&1"; fi
            fi
            if [ "$mode" = "proxmox-lxc" ]; then run_animated "$ERR_LOG" pct exec "$target" -- sh -c "curl -sS https://starship.rs/install.sh | sh -s -- -y >> '$APT_LOG' 2>&1" < /dev/null; else run_animated "$ERR_LOG" sh -c "curl -sS https://starship.rs/install.sh | sh -s -- -y >> '$APT_LOG' 2>&1"; fi
            log_tui_status "${FG_GRN}" "✓" "INSTALLED"
        else
            log_tui_status "${FG_SAP}" "ℹ" "EXISTS"
        fi

        # 5. Inject Configuration Profiles
        log_tui_step "${FG_PCH}" "CONF" "Deploying visual parameters and environment variables"
        if [ "$mode" = "proxmox-lxc" ]; then pct exec "$target" -- mkdir -p /root/.config < /dev/null; else mkdir -p /root/.config < /dev/null; fi
        if [ "$mode" = "proxmox-lxc" ]; then echo "$STARSHIP_CONFIG_CONTENT" | pct exec "$target" -- tee /root/.config/starship.toml > /dev/null; else echo "$STARSHIP_CONFIG_CONTENT" | tee /root/.config/starship.toml > /dev/null; fi

        if check_file "$mode" "$target" "/root/.bashrc"; then
            if [ "$mode" = "proxmox-lxc" ]; then pct exec "$target" -- sh -c "grep -q 'starship init bash' /root/.bashrc || echo 'eval \"\$(starship init bash)\"' >> /root/.bashrc" < /dev/null; else sh -c "grep -q 'starship init bash' /root/.bashrc || echo 'eval \"\$(starship init bash)\"' >> /root/.bashrc" < /dev/null; fi
        fi
        if check_file "$mode" "$target" "/root/.zshrc"; then
            if [ "$mode" = "proxmox-lxc" ]; then pct exec "$target" -- sh -c "grep -q 'starship init zsh' /root/.zshrc || echo 'eval \"\$(starship init zsh)\"' >> /root/.zshrc" < /dev/null; else sh -c "grep -q 'starship init zsh' /root/.zshrc || echo 'eval \"\$(starship init zsh)\"' >> /root/.zshrc" < /dev/null; fi
        fi
        if [ "$os_type" = "alpine" ] && check_file "$mode" "$target" "/root/.profile"; then
            if [ "$mode" = "proxmox-lxc" ]; then pct exec "$target" -- sh -c "grep -q 'starship init' /root/.profile || echo 'eval \"\$(starship init posix)\"' >> /root/.profile" < /dev/null; else sh -c "grep -q 'starship init' /root/.profile || echo 'eval \"\$(starship init posix)\"' >> /root/.profile" < /dev/null; fi
        fi
        log_tui_status "${FG_GRN}" "✓" "CONFIGURED"

        # 6. Application Upgrades Logic
        log_tui_step "${FG_SAP}" "DCKR" "Processing application container lifecycle updates"
        if check_binary "$mode" "$target" "docker"; then
            if [ "$mode" = "proxmox-lxc" ]; then compose_files=$(pct exec "$target" -- find / -maxdepth 4 \( -path /proc -o -path /sys -o -path /dev \) -prune -o \( -name "docker-compose.yml" -o -name "compose.yml" \) -print 2>/dev/null || true); else compose_files=$(find / -maxdepth 4 \( -path /proc -o -path /sys -o -path /dev \) -prune -o \( -name "docker-compose.yml" -o -name "compose.yml" \) -print 2>/dev/null || true); fi
            if [ -n "$compose_files" ]; then
                while read -r compose_path; do
                    [ -z "$compose_path" ] && continue
                    compose_dir=$(dirname "$compose_path")
                    if [ "$mode" = "proxmox-lxc" ]; then
                        run_animated "$ERR_LOG" pct exec "$target" -- sh -c "if docker compose version >/dev/null 2>&1; then cd '$compose_dir' && docker compose pull && docker compose up -d; elif docker-compose version >/dev/null 2>&1; then cd '$compose_dir' && docker-compose pull && docker-compose up -d; fi >> '$APT_LOG' 2>&1" < /dev/null
                    else
                        run_animated "$ERR_LOG" sh -c "if docker compose version >/dev/null 2>&1; then cd '$compose_dir' && docker compose pull && docker compose up -d; elif docker-compose version >/dev/null 2>&1; then cd '$compose_dir' && docker-compose pull && docker-compose up -d; fi >> '$APT_LOG' 2>&1"
                    fi
                done <<< "$compose_files"
                log_tui_status "${FG_GRN}" "✓" "DOCKER COMS"
            else
                log_tui_status "${FG_SAP}" "ℹ" "NO STACKS"
            fi
        else
            log_tui_status "${FG_SAP}" "ℹ" "NO ENGINE"
        fi
    done

    rm -f "$ERR_LOG"
    rm -f "$APT_LOG"
    echo -e "\n${FG_GRN}┌────────────────────────────────────────────────────────────────────────┐${RST}"
    echo -e "${FG_GRN}│${RST} ${BG_GRN} ⚡ COMPLETED: ALL DEPLOYMENT NODE TARGETS OPTIMIZED SUCCESSFULLY ${RST}    ${FG_GRN}│${RST}"
    echo -e "${FG_GRN}└────────────────────────────────────────────────────────────────────────┘${RST}"
}

# --- EXECUTION TRIGGER ---
main "$@" < /dev/null
}
