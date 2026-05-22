#!/usr/bin/env bash

# Exit on error where appropriate
set -Eeuo pipefail

# --- CONFIGURATION ---
INSTALL_PATH="/usr/local/bin/container-updater"
CRON_PATH="/etc/cron.weekly/container-updater"
# Change this to your exact public raw GitHub URL so the cron job can auto-update the script itself later
GITHUB_RAW_URL="https://raw.githubusercontent.com/YOUR_USERNAME/proxmox-autoupdate/main/update.sh"

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

log() {
    echo -e "\n\e[1;34m[SYSTEM-CONTROLLER]\e[0m $1"
}

log_target() {
    echo -e "\e[1;32m[$1]\e[0m $2"
}

# --- ABSTRACT RUNTIME WRAPPERS ---

run_cmd() {
    local type="$1" target="$2"; shift 2
    if [ "$type" = "proxmox-lxc" ]; then pct exec "$target" -- "$@"; else "$@"; fi
}

check_file() {
    local type="$1" target="$2" path="$3"
    if [ "$type" = "proxmox-lxc" ]; then pct exec "$target" -- [ -f "$path" ]; else [ -f "$path" ]; fi
}

check_binary() {
    local type="$1" target="$2" binary="$3"
    if [ "$type" = "proxmox-lxc" ]; then pct exec "$target" -- which "$binary" >/dev/null 2>&1; else command -v "$binary" >/dev/null 2>&1; fi
}

# --- SELF-INSTALLATION LOGIC ---

if [ ! -f "$0" ] || [ "$(basename "$0" 2>/dev/null)" = "bash" ]; then
    log "Execution detected via web piping. Initializing permanent installation..."
    if ! command -v curl >/dev/null 2>&1; then
        if [ -f /etc/debian_version ]; then apt-get update && apt-get install -y curl; fi
        if [ -f /etc/alpine-release ]; then apk update && apk add curl; fi
    fi
    curl -sSL "$GITHUB_RAW_URL" -o "$INSTALL_PATH" && chmod +x "$INSTALL_PATH"
    
    cat << EOF > "$CRON_PATH"
#!/bin/sh
curl -sSL "$GITHUB_RAW_URL" -o "$INSTALL_PATH" && chmod +x "$INSTALL_PATH"
"$INSTALL_PATH" --cron
EOF
    chmod +x "$CRON_PATH"
    log "Weekly cron distribution profile updated successfully."
fi

# --- ENVIRONMENT DETECTION & TARGET ROUTING ---

targets=()
target_modes=()

if command -v pct >/dev/null 2>&1; then
    log "Proxmox Environment detected. Mapping hypervisor node + child containers..."
    
    # 1. First target: The main Proxmox host system itself
    targets+=("pve-host-node")
    target_modes+=("pve-host")
    
    # 2. Subsequent targets: All running containers
    vmid_list=$(pct list | awk 'NR>1 && $2=="running" {print $1}')
    for vmid in $vmid_list; do
        targets+=("$vmid")
        target_modes+=("proxmox-lxc")
    done
else
    log "Standalone Server/VM detected. Running execution logic natively..."
    targets+=("local-machine")
    target_modes+=("local")
fi

# --- SYSTEM INTEGRATION PASS ---

for i in "${!targets[@]}"; do
    target="${targets[$i]}"
    mode="${target_modes[$i]}"

    log_target "$target" "Configuring software profiles..."

    # Determine underlying distribution matrix
    if [ "$mode" = "pve-host" ]; then
        os_type="debian"
    elif check_file "$mode" "$target" "/etc/alpine-release"; then
        os_type="alpine"
    elif check_file "$mode" "$target" "/etc/debian_version"; then
        os_type="debian"
    else
        log_target "$target" "Unknown system layout. Skipping core updates."
        continue
    fi

    # 1. System Upgrades & Unattended Automation Configurations
    if [ "$mode" = "pve-host" ]; then
        log_target "$target" "Running Proxmox non-interactive system distribution upgrades..."
        # pveupgrade wraps apt-get dist-upgrade natively to preserve node architecture definitions safely
        env DEBIAN_FRONTEND=noninteractive apt-get update -y
        env DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y --allow-downgrades

        log_target "$target" "Setting up hypervisor unattended updates..."
        env DEBIAN_FRONTEND=noninteractive apt-get install -y unattended-upgrades apt-listchanges
        debconf-set-selections <<< "unattended-upgrades unattended-upgrades/enable_auto_updates boolean true"
        dpkg-reconfigure -f noninteractive unattended-upgrades

    elif [ "$os_type" = "debian" ]; then
        log_target "$target" "Running container package synchronization (apt)..."
        run_cmd "$mode" "$target" env DEBIAN_FRONTEND=noninteractive apt-get update -y
        run_cmd "$mode" "$target" env DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
        run_cmd "$mode" "$target" env DEBIAN_FRONTEND=noninteractive apt-get install -y unattended-upgrades apt-listchanges
        if [ "$mode" = "proxmox-lxc" ]; then
            pct exec "$target" -- debconf-set-selections <<< "unattended-upgrades unattended-upgrades/enable_auto_updates boolean true"
        else
            debconf-set-selections <<< "unattended-upgrades unattended-upgrades/enable_auto_updates boolean true"
        fi
        run_cmd "$mode" "$target" dpkg-reconfigure -f noninteractive unattended-upgrades

    elif [ "$os_type" = "alpine" ]; then
        log_target "$target" "Running container package synchronization (apk)..."
        run_cmd "$mode" "$target" apk update
        run_cmd "$mode" "$target" apk upgrade
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

    # 2. Starship Binary Engine Setup
    log_target "$target" "Validating Starship engine state..."
    if ! check_binary "$mode" "$target" "starship"; then
        if [ "$os_type" = "debian" ]; then run_cmd "$mode" "$target" env DEBIAN_FRONTEND=noninteractive apt-get install -y curl; fi
        if [ "$os_type" = "alpine" ]; then run_cmd "$mode" "$target" apk add curl; fi
        
        if [ "$mode" = "proxmox-lxc" ]; then
            pct exec "$target" -- sh -c "curl -sS https://starship.rs/install.sh | sh -s -- -y"
        else
            sh -c "curl -sS https://starship.rs/install.sh | sh -s -- -y"
        fi
    fi

    # 3. Inject Config Files
    run_cmd "$mode" "$target" mkdir -p /root/.config
    if [ "$mode" = "proxmox-lxc" ]; then
        echo "$STARSHIP_CONFIG_CONTENT" | pct exec "$target" -- tee /root/.config/starship.toml > /dev/null
    else
        echo "$STARSHIP_CONFIG_CONTENT" | tee /root/.config/starship.toml > /dev/null
    fi

    # 4. Global Prompt Hook Integrations
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

    # 5. Application Stack Upgrades (Docker Compose Deployments)
    if check_binary "$mode" "$target" "docker"; then
        log_target "$target" "Docker engine identified. Scanning application spaces..."
        if [ "$mode" = "proxmox-lxc" ]; then
            compose_files=$(pct exec "$target" -- find / -maxdepth 4 -name "docker-compose.yml" -o -name "compose.yml" 2>/dev/null || true)
        else
            compose_files=$(find / -maxdepth 4 -name "docker-compose.yml" -o -name "compose.yml" 2>/dev/null || true)
        fi

        if [ -n "$compose_files" ]; then
            while read -r compose_path; do
                [ -z "$compose_path" ] && continue
                compose_dir=$(dirname "$compose_path")
                log_target "$target" "Upgrading stack dependencies located in: $compose_dir"
                
                if [ "$mode" = "proxmox-lxc" ]; then
                    if pct exec "$target" -- docker compose version >/dev/null 2>&1; then pct exec "$target" -- sh -c "cd $compose_dir && docker compose pull && docker compose up -d";
                    elif pct exec "$target" -- docker-compose version >/dev/null 2>&1; then pct exec "$target" -- sh -c "cd $compose_dir && docker-compose pull && docker-compose up -d"; fi
                else
                    if docker compose version >/dev/null 2>&1; then sh -c "cd $compose_dir && docker compose pull && docker compose up -d";
                    elif docker-compose version >/dev/null 2>&1; then sh -c "cd $compose_dir && docker-compose pull && docker-compose up -d"; fi
                fi
            done <<< "$compose_files"
        fi
    fi
done

log "Universal optimization run finished."