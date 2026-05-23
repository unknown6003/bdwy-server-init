#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -Eeuo pipefail

# --- ENFORCE CORE SYSTEM FILEPATH LAYOUTS ---
mkdir -p /usr/local/bin /etc/cron.weekly /root/.config

# --- CONFIGURATION VARIABLES ---
INSTALL_PATH="/usr/local/bin/container-updater"
CRON_PATH="/etc/cron.weekly/container-updater"
GITHUB_RAW_URL="https://raw.githubusercontent.com/unknown6003/bdwy-server-init/refs/heads/main/auto-setup-bdwy.sh"

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
    printf "  ${status_color}${RST}${status_color}${tag}${RST}${status_color}${RST} %-50s" "$msg"
}

log_tui_status() {
    local color="$1" symbol="$2" text="$3"
    echo -e "[${color}${symbol}${RST}] ${color}${text}${RST}"
}

show_tui_progress() {
    local percent=$1
    local bar_len=24
    local filled=$(( percent * bar_len / 100 ))
    local empty=$(( bar_len - filled ))
    
    printf "\r  ${FG_SAP}${RST}${BG_SAP} PROGRESS ${RST}${FG_SAP}${RST} ["
    printf "${FG_SAP}%${filled}s${RST}" "" | tr ' ' '█'
    printf "%${empty}s" "" | tr ' ' ' '
    printf "] %d%%" "$percent"
    if [ "$percent" -eq 100 ] || [ "$percent" -eq 5 ]; then printf "\n"; fi
}

# --- ABSTRACT RUNTIME LAYER ---
run_cmd() {
    local type="$1" target="$2"; shift 2
    if [ "$type" = "proxmox-lxc" ]; then
        pct exec "$target" -- "$@" < /dev/null
    else
        "$@" < /dev/null
    fi
}

check_file() {
    local type="$1" target="$2" path="$3"
    if [ "$type" = "proxmox-lxc" ]; then pct exec "$target" -- [ -f "$path" ] < /dev/null; else [ -f "$path" ]; fi
}

check_binary() {
    local type="$1" target="$2" binary="$3"
    if [ "$type" = "proxmox-lxc" ]; then pct exec "$target" -- which "$binary" < /dev/null >/dev/null 2>&1; else command -v "$binary" < /dev/null >/dev/null 2>&1; fi
}

# --- DECOUPLED PIPELINE REGISTRATION ENGINE ---
if [ ! -f "$0" ] || [ "$(basename "$0" 2>/dev/null)" = "bash" ]; then
    log_banner
    log_tui_step "${FG_PCH}" "INIT" "Writing core controller engine shell payload"
    
    if curl -fsSL "$GITHUB_RAW_URL" -o /tmp/updater-bin.tmp < /dev/null; then
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

# --- PLATFORM IDENTIFICATION PASS ---
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

# Create a secure scratch space for error capture
ERR_LOG="/tmp/updater_stderr.log"

# --- MAIN TUI CORE RUNTIME ---
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
    show_tui_progress 20
    log_tui_step "${FG_YLW}" "REPO" "Refreshing system package architectures"
    
    set +e # Temporarily allow non-zero returns so we can catch errors explicitly
    if [ "$mode" = "pve-host" ]; then
        if [ -f /etc/apt/sources.list.d/pve-enterprise.list ]; then sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/pve-enterprise.list || true; fi
        if [ -f /etc/apt/sources.list.d/proxmox.sources ]; then sed -i 's/enterprise.proxmox.com/download.proxmox.com/g' /etc/apt/sources.list.d/proxmox.sources || true; fi
        if ! grep -q "pve-no-subscription" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then echo "deb http://download.proxmox.com/debian/pve trixie pve-no-subscription" > /etc/apt/sources.list.d/pve-no-sub.list; fi
        
        # Run package sync while routing standard streams safely away from stdin
        env DEBIAN_FRONTEND=noninteractive apt-get update -y < /dev/null >/dev/null 2> "$ERR_LOG"
        env DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y --allow-downgrades < /dev/null >/dev/null 2>> "$ERR_LOG"
        cmd_status=$?
    elif [ "$os_type" = "debian" ]; then
        if [ "$mode" = "proxmox-lxc" ]; then
            pct exec "$target" -- sh -c "env DEBIAN_FRONTEND=noninteractive apt-get update -y && env DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y" < /dev/null >/dev/null 2> "$ERR_LOG"
        else
            env DEBIAN_FRONTEND=noninteractive apt-get update -y < /dev/null >/dev/null 2> "$ERR_LOG"
            env DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y < /dev/null >/dev/null 2>> "$ERR_LOG"
        fi
        cmd_status=$?
    elif [ "$os_type" = "alpine" ]; then
        if [ "$mode" = "proxmox-lxc" ]; then
            pct exec "$target" -- sh -c "apk update && apk upgrade" < /dev/null >/dev/null 2> "$ERR_LOG"
        else
            apk update < /dev/null >/dev/null 2> "$ERR_LOG"
            apk upgrade < /dev/null >/dev/null 2>> "$ERR_LOG"
        fi
        cmd_status=$?
    fi
    set -e # Restore strict failure settings

    if [ "$cmd_status" -ne 0 ]; then
        log_tui_status "${FG_RED}" "✘" "CRASHED"
        echo -e "\n${FG_RED}┌─── CRITICAL SYSTEM DIAGNOSTIC ERROR ERROR LOG ─────────────────────────┐${RST}"
        cat "$ERR_LOG" | sed 's/^/  /' || echo "  Unknown structural system crash state."
        echo -e "${FG_RED}└────────────────────────────────────────────────────────────────────────┘${RST}"
        exit 1
    fi
    log_tui_status "${FG_GRN}" "✓" "UPDATED"

    # 2. Unattended Engine Links
    show_tui_progress 40
    log_tui_step "${FG_YLW}" "AUTO" "Injecting unattended processing background engines"
    if [ "$os_type" = "debian" ] || [ "$mode" = "pve-host" ]; then
        if [ "$mode" = "pve-host" ]; then
            env DEBIAN_FRONTEND=noninteractive apt-get install -y unattended-upgrades apt-listchanges < /dev/null >/dev/null 2>&1
            echo "unattended-upgrades unattended-upgrades/enable_auto_updates boolean true" | debconf-set-selections < /dev/null >/dev/null 2>&1
            dpkg-reconfigure -f noninteractive unattended-upgrades < /dev/null >/dev/null 2>&1
        elif [ "$mode" = "proxmox-lxc" ]; then
            pct exec "$target" -- sh -c "env DEBIAN_FRONTEND=noninteractive apt-get install -y unattended-upgrades apt-listchanges" < /dev/null >/dev/null 2>&1
            pct exec "$target" -- sh -c "echo 'unattended-upgrades unattended-upgrades/enable_auto_updates boolean true' | debconf-set-selections" < /dev/null >/dev/null 2>&1
            pct exec "$target" -- dpkg-reconfigure -f noninteractive unattended-upgrades < /dev/null >/dev/null 2>&1
        else
            env DEBIAN_FRONTEND=noninteractive apt-get install -y unattended-upgrades apt-listchanges < /dev/null >/dev/null 2>&1
            echo "unattended-upgrades unattended-upgrades/enable_auto_updates boolean true" | debconf-set-selections < /dev/null >/dev/null 2>&1
            dpkg-reconfigure -f noninteractive unattended-upgrades < /dev/null >/dev/null 2>&1
        fi
    elif [ "$os_type" = "alpine" ]; then
        run_cmd "$mode" "$target" apk add cronie
        run_cmd "$mode" "$target" rc-update add cronie default || true
        run_cmd "$mode" "$target" rc-service cronie start || true
        cron_script="#!/bin/sh\napk update && apk upgrade"
        if [ "$mode" = "proxmox-lxc" ]; then echo -e "$cron_script" | pct exec "$target" -- tee /etc/periodic/daily/apk-upgrade > /dev/null; else echo -e "$cron_script" | tee /etc/periodic/daily/apk-upgrade > /dev/null; fi
        run_cmd "$mode" "$target" chmod +x /etc/periodic/daily/apk-upgrade
    fi
    log_tui_status "${FG_GRN}" "✓" "ACTIVE"

    # 3. Starship Target Configurations
    show_tui_progress 60
    log_tui_step "${FG_PCH}" "SHSH" "Verifying localized Starship engine prompt presence"
    if ! check_binary "$mode" "$target" "starship"; then
        if [ "$os_type" = "debian" ]; then run_cmd "$mode" "$target" env DEBIAN_FRONTEND=noninteractive apt-get install -y curl; fi
        if [ "$os_type" = "alpine" ]; then run_cmd "$mode" "$target" apk add curl; fi
        if [ "$mode" = "proxmox-lxc" ]; then pct exec "$target" -- sh -c "curl -sS https://starship.rs/install.sh | sh -s -- -y" < /dev/null >/dev/null 2>&1; else sh -c "curl -sS https://starship.rs/install.sh | sh -s -- -y" < /dev/null >/dev/null 2>&1; fi
        log_tui_status "${FG_GRN}" "✓" "INSTALLED"
    else
        log_tui_status "${FG_SAP}" "ℹ" "EXISTS"
    fi

    # 4. Inject Configuration Profiles
    show_tui_progress 80
    log_tui_step "${FG_PCH}" "CONF" "Deploying visual parameters and environment variables"
    run_cmd "$mode" "$target" mkdir -p /root/.config
    if [ "$mode" = "proxmox-lxc" ]; then echo "$STARSHIP_CONFIG_CONTENT" | pct exec "$target" -- tee /root/.config/starship.toml > /dev/null; else echo "$STARSHIP_CONFIG_CONTENT" | tee /root/.config/starship.toml > /dev/null; fi

    if check_file "$mode" "$target" "/root/.bashrc"; then
        if [ "$mode" = "proxmox-lxc" ]; then
            if ! pct exec "$target" -- grep -q "starship init bash" /root/.bashrc; then echo 'eval "$(starship init bash)"' | pct exec "$target" -- tee -a /root/.bashrc > /dev/null; fi
        else
            if ! grep -q "starship init bash" /root/.bashrc; then echo 'eval "$(starship init bash)"' | tee -a /root/.bashrc > /dev/null; fi
        fi
    fi
    if check_file "$mode" "$target" "/root/.zshrc"; then
        if [ "$mode" = "proxmox-lxc" ]; then
            if ! pct exec "$target" -- grep -q "starship init zsh" /root/.zshrc; then echo 'eval "$(starship init zsh)"' | pct exec "$target" -- tee -a /root/.zshrc > /dev/null; fi
        else
            if ! grep -q "starship init zsh" /root/.zshrc; then echo 'eval "$(starship init zsh)"' | tee -a /root/.zshrc > /dev/null; fi
        fi
    fi
    if [ "$os_type" = "alpine" ] && check_file "$mode" "$target" "/root/.profile"; then
        if [ "$mode" = "proxmox-lxc" ]; then
            if ! pct exec "$target" -- grep -q "starship init" /root/.profile; then echo 'eval "$(starship init posix)"' | pct exec "$target" -- tee -a /root/.profile > /dev/null; fi
        else
            if ! grep -q "starship init" /root/.profile; then echo 'eval "$(starship init posix)"' | tee -a /root/.profile > /dev/null; fi
        fi
    fi
    log_tui_status "${FG_GRN}" "✓" "CONFIGURED"

    # 5. Application Upgrades Logic
    show_tui_progress 100
    log_tui_step "${FG_SAP}" "DCKR" "Processing application container lifecycle updates"
    if check_binary "$mode" "$target" "docker"; then
        if [ "$mode" = "proxmox-lxc" ]; then compose_files=$(pct exec "$target" -- find / -maxdepth 4 -name "docker-compose.yml" -o -name "compose.yml" 2>/dev/null || true); else compose_files=$(find / -maxdepth 4 -name "docker-compose.yml" -o -name "compose.yml" 2>/dev/null || true); fi
        if [ -n "$compose_files" ]; then
            while read -r compose_path; do
                [ -z "$compose_path" ] && continue
                compose_dir=$(dirname "$compose_path")
                if [ "$mode" = "proxmox-lxc" ]; then
                    if pct exec "$target" -- docker compose version < /dev/null >/dev/null 2>&1; then pct exec "$target" -- sh -c "cd $compose_dir && docker compose pull && docker compose up -d" < /dev/null >/dev/null 2>&1;
                    elif pct exec "$target" -- docker-compose version < /dev/null >/dev/null 2>&1; then pct exec "$target" -- sh -c "cd $compose_dir && docker-compose pull && docker-compose up -d" < /dev/null >/dev/null 2>&1; fi
                else
                    if docker compose version < /dev/null >/dev/null 2>&1; then sh -c "cd $compose_dir && docker compose pull && docker compose up -d" < /dev/null >/dev/null 2>&1;
                    elif docker-compose version < /dev/null >/dev/null 2>&1; then sh -c "cd $compose_dir && docker-compose pull && docker-compose up -d" < /dev/null >/dev/null 2>&1; fi
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

# Clean up working log directories cleanly
rm -f "$ERR_LOG"

echo -e "\n${FG_GRN}┌────────────────────────────────────────────────────────────────────────┐${RST}"
echo -e "${FG_GRN}│${RST} ${BG_GRN} ⚡ COMPLETED: ALL DEPLOYMENT NODE TARGETS OPTIMIZED SUCCESSFULLY ${RST}    ${FG_GRN}│${RST}"
echo -e "${FG_GRN}└────────────────────────────────────────────────────────────────────────┘${RST}"
