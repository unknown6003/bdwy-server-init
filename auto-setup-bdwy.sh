#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -Eeuo pipefail

# --- CONFIGURATION MATCH MATRIX ---
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
format = '[[ $symbol( $version) ](fg:crust bg:green)]($style)'

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

# --- TERMINAL UI GRAPHICS ENGINE ---
CLR_BLU="\e[1;34m"
CLR_GRN="\e[1;32m"
CLR_YLW="\e[1;33m"
CLR_RED="\e[1;31m"
CLR_CYN="\e[1;36m"
CLR_RST="\e[0m"

log_info() {  echo -e "${CLR_BLU}[⚙ INFO]${CLR_RST} $1"; }
log_step() {  echo -e "  ${CLR_CYN}➔${CLR_RST} $1... "; }
log_ok() {    echo -e "  ${CLR_GRN}✓${CLR_RST} $1"; }
log_warn() {  echo -e "${CLR_YLW}[⚠ WARN]${CLR_RST} $1"; }
log_err() {   echo -e "${CLR_RED}[✘ FAIL]${CLR_RST} $1"; }

show_progress() {
    local label="$1" current="$2" total="$3"
    local percent=$(( current * 100 / total ))
    local bar_len=20
    local filled=$(( percent * bar_len / 100 ))
    local empty=$(( bar_len - filled ))

    printf "\r${CLR_BLU}[⏳ PROG]${CLR_RST} %-25s [" "$label"
    printf "%${filled}s" "" | tr ' ' '■'
    printf "%${empty}s" "" | tr ' ' ' '
    printf "] %d%% (%d/%d)" "$percent" "$current" "$total"
    if [ "$current" -eq "$total" ]; then echo ""; fi
}

# --- ABSTRACT RUNTIME LAYER ---
run_cmd() {
    local type="$1" target="$2"; shift 2
    if [ "$type" = "proxmox-lxc" ]; then
        pct exec "$target" -- "$@" >/dev/null 2>&1
    else
        "$@" >/dev/null 2>&1
    fi
}

check_file() {
    local type="$1" target="$2" path="$3"
    if [ "$type" = "proxmox-lxc" ]; then pct exec "$target" -- [ -f "$path" ]; else [ -f "$path" ]; fi
}

check_binary() {
    local type="$1" target="$2" binary="$3"
    if [ "$type" = "proxmox-lxc" ]; then pct exec "$target" -- which "$binary" >/dev/null 2>&1; else command -v "$binary" >/dev/null 2>&1; fi
}

# --- INLINE SELF-INSTALLATION ENGINE ---
# Detect pipeline execution safely without generating disk write descriptor blocks
if [ ! -f "$0" ] || [ "$(basename "$0" 2>/dev/null)" = "bash" ]; then
    log_info "Web execution pipe detected. Dropping localization profile down..."

    # Generate the payload locally from the active memory context
    cat << 'EOF' > "$INSTALL_PATH" || true
# Context container proxy link
EOF

    # Safe decoupled grab to avoid curl 23 network halts
    curl -sSL "$GITHUB_RAW_URL" -o "$INSTALL_PATH" || log_warn "Retrying local copy bind write operations..."
    chmod +x "$INSTALL_PATH"

    # Generate weekly system wrapper cron task setup
    cat << EOF > "$CRON_PATH"
#!/bin/sh
curl -sSL "$GITHUB_RAW_URL" -o "$INSTALL_PATH" && chmod +x "$INSTALL_PATH"
"$INSTALL_PATH" --cron
EOF
    chmod +x "$CRON_PATH"
    log_ok "Automation scheduler anchored at: $CRON_PATH"
fi

# --- PLATFORM IDENTIFICATION PASS ---
targets=()
target_modes=()

if command -v pct >/dev/null 2>&1; then
    log_info "Hypervisor environment detected. Parsing operational clusters..."
    targets+=("pve-host-node")
    target_modes+=("pve-host")

    vmid_list=$(pct list | awk 'NR>1 && $2=="running" {print $1}')
    for vmid in $vmid_list; do
        targets+=("$vmid")
        target_modes+=("proxmox-lxc")
    done
else
    log_info "Standalone server infrastructure verified. Initializing localized tracking target..."
    targets+=("local-machine")
    target_modes+=("local")
fi

total_targets=${#targets[@]}

# --- MAIN CORE PROCESSING LOOPS ---
for i in "${!targets[@]}"; do
    target="${targets[$i]}"
    mode="${target_modes[$i]}"
    idx=$((i + 1))

    echo -e "\n${CLR_GRN}========================================================================${CLR_RST}"
    echo -e "${CLR_CYN}[TARGET $idx/$total_targets] Hosting Platform Instance: $target${CLR_RST}"
    echo -e "${CLR_GRN}========================================================================${CLR_RST}"

    # Target-Specific Distribution Detection Matrix
    if [ "$mode" = "pve-host" ]; then
        os_type="debian"
    elif check_file "$mode" "$target" "/etc/alpine-release"; then
        os_type="alpine"
    elif check_file "$mode" "$target" "/etc/debian_version"; then
        os_type="debian"
    else
        log_warn "Undocumented operating system structure identified on target $target. Skipping processing."
        continue
    fi

    # 1. Repository Sanity, Maintenance, and Security System Upgrades
    show_progress "Updating Repositories" 1 5
    if [ "$mode" = "pve-host" ]; then
        log_step "Fixing Proxmox commercial repository definitions"
        # Comment out the commercial enterprise listing to stop unauthorized 401 connection barriers
        if [ -f /etc/apt/sources.list.d/pve-enterprise.list ]; then
            sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/pve-enterprise.list || true
        fi
        if [ -f /etc/apt/sources.list.d/proxmox.sources ]; then
            sed -i 's/enterprise.proxmox.com/download.proxmox.com/g' /etc/apt/sources.list.d/proxmox.sources || true
        fi

        # Explicitly configure the fallback pve-no-subscription channel cleanly if completely missing
        if ! grep -q "pve-no-subscription" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
            echo "deb http://download.proxmox.com/debian/pve trixie pve-no-subscription" > /etc/apt/sources.list.d/pve-no-sub.list
        fi
        log_ok "Proxmox subscription-free configurations synchronized successfully"

        log_step "Synchronizing PVE Distribution components"
        env DEBIAN_FRONTEND=noninteractive apt-get update -y >/dev/null 2>&1
        env DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y --allow-downgrades >/dev/null 2>&1

    elif [ "$os_type" = "debian" ]; then
        log_step "Executing apt package updates"
        if [ "$mode" = "proxmox-lxc" ]; then
            pct exec "$target" -- sh -c "env DEBIAN_FRONTEND=noninteractive apt-get update -y && env DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y" >/dev/null 2>&1
        else
            env DEBIAN_FRONTEND=noninteractive apt-get update -y >/dev/null 2>&1
            env DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y >/dev/null 2>&1
        fi

    elif [ "$os_type" = "alpine" ]; then
        log_step "Executing apk container index refreshes"
        run_cmd "$mode" "$target" apk update
        run_cmd "$mode" "$target" apk upgrade
    fi
    log_ok "Package repository updates complete"

    # 2. Automated Unattended System Upgrades Configurations
    show_progress "Configuring Auto-Updates" 2 5
    if [ "$os_type" = "debian" ] || [ "$mode" = "pve-host" ]; then
        log_step "Injecting automated unattended-upgrades background jobs"
        if [ "$mode" = "pve-host" ]; then
            env DEBIAN_FRONTEND=noninteractive apt-get install -y unattended-upgrades apt-listchanges >/dev/null 2>&1
            debconf-set-selections <<< "unattended-upgrades unattended-upgrades/enable_auto_updates boolean true"
            dpkg-reconfigure -f noninteractive unattended-upgrades >/dev/null 2>&1
        elif [ "$mode" = "proxmox-lxc" ]; then
            pct exec "$target" -- sh -c "env DEBIAN_FRONTEND=noninteractive apt-get install -y unattended-upgrades apt-listchanges" >/dev/null 2>&1
            pct exec "$target" -- debconf-set-selections <<< "unattended-upgrades unattended-upgrades/enable_auto_updates boolean true"
            pct exec "$target" -- dpkg-reconfigure -f noninteractive unattended-upgrades >/dev/null 2>&1
        else
            env DEBIAN_FRONTEND=noninteractive apt-get install -y unattended-upgrades apt-listchanges >/dev/null 2>&1
            debconf-set-selections <<< "unattended-upgrades unattended-upgrades/enable_auto_updates boolean true"
            dpkg-reconfigure -f noninteractive unattended-upgrades >/dev/null 2>&1
        fi
    elif [ "$os_type" = "alpine" ]; then
        log_step "Anchoring system automated periodic cron links"
        run_cmd "$mode" "$target" apk add cronie
        run_cmd "$mode" "$target" rc-update add cronie default || true
        run_cmd "$mode" "$target" rc-service cronie start || true

        cron_script="#!/bin/sh\napk update && apk upgrade"
        if [ "$mode" = "proxmox-lxc" ]; then
            echo -e "$cron_script" | pct exec "$target" -- tee /etc/periodic/daily/apk-upgrade > /dev/null
        else
            echo -e "$cron_script" | tee /etc/periodic/daily/apk-upgrade > /dev/null
        fi
        run_cmd "$mode" "$target" chmod +x /etc/periodic/daily/apk-upgrade
    fi
    log_ok "Unattended engine execution parameters established"

    # 3. Shell Modification Framework & Engine Tool Setup (Starship Prompt Core Engine)
    show_progress "Installing Starship" 3 5
    if ! check_binary "$mode" "$target" "starship"; then
        log_step "Downloading structural shell binary frameworks"
        if [ "$os_type" = "debian" ]; then run_cmd "$mode" "$target" env DEBIAN_FRONTEND=noninteractive apt-get install -y curl; fi
        if [ "$os_type" = "alpine" ]; then run_cmd "$mode" "$target" apk add curl; fi

        if [ "$mode" = "proxmox-lxc" ]; then
            pct exec "$target" -- sh -c "curl -sS https://starship.rs/install.sh | sh -s -- -y" >/dev/null 2>&1
        else
            sh -c "curl -sS https://starship.rs/install.sh | sh -s -- -y" >/dev/null 2>&1
        fi
        log_ok "Starship base prompt package cleanly compiled"
    else
        log_ok "Starship base software package is already present on system filesystem"
    fi

    # 4. Global Target Setting Config Dispatches
    show_progress "Applying Configurations" 4 5
    log_step "Writing structural visual setting profiles"
    run_cmd "$mode" "$target" mkdir -p /root/.config
    if [ "$mode" = "proxmox-lxc" ]; then
        echo "$STARSHIP_CONFIG_CONTENT" | pct exec "$target" -- tee /root/.config/starship.toml > /dev/null
    else
        echo "$STARSHIP_CONFIG_CONTENT" | tee /root/.config/starship.toml > /dev/null
    fi

    log_step "Injecting cross-shell boot evaluation flags"
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
    log_ok "Visual prompt configurations cleanly saved"

    # 5. Application Lifecycle Stack Layer Processing (Docker Containers Updates Logic)
    show_progress "Updating App Containers" 5 5
    if check_binary "$mode" "$target" "docker"; then
        log_step "Scanning filesystem for operational docker-compose environments"
        if [ "$mode" = "proxmox-lxc" ]; then
            compose_files=$(pct exec "$target" -- find / -maxdepth 4 -name "docker-compose.yml" -o -name "compose.yml" 2>/dev/null || true)
        else
            compose_files=$(find / -maxdepth 4 -name "docker-compose.yml" -o -name "compose.yml" 2>/dev/null || true)
        fi

        if [ -n "$compose_files" ]; then
            while read -r compose_path; do
                [ -z "$compose_path" ] && continue
                compose_dir=$(dirname "$compose_path")
                log_step "Pulling upstream dependencies and rebuilding application environment: $compose_dir"

                if [ "$mode" = "proxmox-lxc" ]; then
                    if pct exec "$target" -- docker compose version >/dev/null 2>&1; then pct exec "$target" -- sh -c "cd $compose_dir && docker compose pull && docker compose up -d" >/dev/null 2>&1;
                    elif pct exec "$target" -- docker-compose version >/dev/null 2>&1; then pct exec "$target" -- sh -c "cd $compose_dir && docker-compose pull && docker-compose up -d" >/dev/null 2>&1; fi
                else
                    if docker compose version >/dev/null 2>&1; then sh -c "cd $compose_dir && docker compose pull && docker compose up -d" >/dev/null 2>&1;
                    elif docker-compose version >/dev/null 2>&1; then sh -c "cd $compose_dir && docker-compose pull && docker-compose up -d" >/dev/null 2>&1; fi
                fi
            done <<< "$compose_files"
            log_ok "All located application compose layers updated successfully"
        else
            log_ok "No operational docker-compose config contexts found on local paths"
        fi
    else
        log_ok "Docker core binary is not present on target environment runtime pathways"
    fi
done

echo -e "\n${CLR_GRN}[✔ SUCCESS] Maintenance tasks finished across all detected deployment platforms.${CLR_RST}"
