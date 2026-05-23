#!/usr/bin/env bash

{
set -Eeuo pipefail

# --- CONFIGURATION ---
SCRIPT_VERSION="2026-05-23T06:35Z-starship-binary-fallback"
INSTALL_PATH="/usr/local/bin/container-updater"
CRON_PATH="/etc/cron.weekly/container-updater"
GITHUB_RAW_URL="https://raw.githubusercontent.com/unknown6003/bdwy-server-init/refs/heads/main/auto-setup-bdwy.sh"
STARSHIP_TOML_CONTENT='"$schema" = '\''https://starship.rs/config-schema.json'\''

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

palette = '\''catppuccin_mocha'\''

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
format = '\''[ $user]($style)'\''

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
format = '\''[[ $symbol $branch ](fg:crust bg:yellow)]($style)'\''

[git_status]
style = "bg:yellow"
format = '\''[[($all_status$ahead_behind )](fg:crust bg:yellow)]($style)'\''

[nodejs]
symbol = ""
style = "bg:green"
format = '\''[[ $symbol( $version) ](fg:crust bg:green)]($style)'\''

[c]
symbol = " "
style = "bg:green"
format = '\''[[ $symbol( $version) ](fg:crust bg:green)]($style)'\''

[rust]
symbol = ""
style = "bg:green"
format = '\''[[ $symbol( $version) ](fg:crust bg:green)]($style)'\''

[golang]
symbol = ""
style = "bg:green"
format = '\''[[ $symbol( $version) ](fg:crust bg:green)]($style)'\''

[php]
symbol = ""
style = "bg:green"
format = '\''[[ $symbol( $version) ](fg:crust bg:green)]($style)'\''

[java]
symbol = " "
style = "bg:green"
format = '\''[[ $symbol( $version) ](fg:crust bg:green)]($style)'\''

[kotlin]
symbol = ""
style = "bg:green"
format = '\''[[ $symbol( $version) ](fg:crust bg:green)]($style)'\''

[haskell]
symbol = ""
style = "bg:green"
format = '\''[[ $symbol( $version) ](fg:crust bg:green)]($style)'\''

[python]
symbol = ""
style = "bg:green"
format = '\''[[ $symbol( $version)(\(#$virtualenv\)) ](fg:crust bg:green)]($style)'\''

[docker_context]
symbol = ""
style = "bg:sapphire"
format = '\''[[ $symbol( $context) ](fg:crust bg:sapphire)]($style)'\''

[conda]
symbol = "  "
style = "fg:crust bg:sapphire"
format = '\''[$symbol$environment ]($style)'\''
ignore_base = false

[time]
disabled = false
time_format = "%R"
style = "bg:lavender"
format = '\''[[  $time ](fg:crust bg:lavender)]($style)'\''

[line_break]
disabled = false

[character]
disabled = false
success_symbol = '\''[❯](bold fg:green)'\''
error_symbol = '\''[❯](bold fg:red)'\''
vimcmd_symbol = '\''[❮](bold fg:green)'\''
vimcmd_replace_one_symbol = '\''[❮](bold fg:lavender)'\''
vimcmd_replace_symbol = '\''[❮](bold fg:lavender)'\''
vimcmd_visual_symbol = '\''[❮](bold fg:yellow)'\''

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

[palettes.catppuccin_frappe]
rosewater = "#f2d5cf"
flamingo = "#eebebe"
pink = "#f4b8e4"
mauve = "#ca9ee6"
red = "#e78284"
maroon = "#ea999c"
peach = "#ef9f76"
yellow = "#e5c890"
green = "#a6d189"
teal = "#81c8be"
sky = "#99d1db"
sapphire = "#85c1dc"
blue = "#8caaee"
lavender = "#babbf1"
text = "#c6d0f5"
subtext1 = "#b5bfe2"
subtext0 = "#a5adce"
overlay2 = "#949cbb"
overlay1 = "#838ba7"
overlay0 = "#737994"
surface2 = "#626880"
surface1 = "#51576d"
surface0 = "#414559"
base = "#303446"
mantle = "#292c3c"
crust = "#232634"

[palettes.catppuccin_latte]
rosewater = "#dc8a78"
flamingo = "#dd7878"
pink = "#ea76cb"
mauve = "#8839ef"
red = "#d20f39"
maroon = "#e64553"
peach = "#fe640b"
yellow = "#df8e1d"
green = "#40a02b"
teal = "#179299"
sky = "#04a5e5"
sapphire = "#209fb5"
blue = "#1e66f5"
lavender = "#7287fd"
text = "#4c4f69"
subtext1 = "#5c5f77"
subtext0 = "#6c6f85"
overlay2 = "#7c7f93"
overlay1 = "#8c8fa1"
overlay0 = "#9ca0b0"
surface2 = "#acb0be"
surface1 = "#bcc0cc"
surface0 = "#ccd0da"
base = "#eff1f5"
mantle = "#e6e9ef"
crust = "#dce0e8"

[palettes.catppuccin_macchiato]
rosewater = "#f4dbd6"
flamingo = "#f0c6c6"
pink = "#f5bde6"
mauve = "#c6a0f6"
red = "#ed8796"
maroon = "#ee99a0"
peach = "#f5a97f"
yellow = "#eed49f"
green = "#a6da95"
teal = "#8bd5ca"
sky = "#91d7e3"
sapphire = "#7dc4e4"
blue = "#8aadf4"
lavender = "#b7bdf8"
text = "#cad3f5"
subtext1 = "#b8c0e0"
subtext0 = "#a5adcb"
overlay2 = "#939ab7"
overlay1 = "#8087a2"
overlay0 = "#6e738d"
surface2 = "#5b6078"
surface1 = "#494d64"
surface0 = "#363a4f"
base = "#24273a"
mantle = "#1e2030"
crust = "#181926"
'

# --- TUI ENGINE ---
FG_CYN="\e[38;5;117m"
FG_GRN="\e[38;5;115m"
FG_YLW="\e[38;5;221m"
FG_RED="\e[38;5;204m"
FG_BLU="\e[38;5;81m"
FG_MAG="\e[38;5;213m"
FG_ORG="\e[38;5;208m"
FG_DIM="\e[2m"
RST="\e[0m"

IS_TTY=0
if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
    IS_TTY=1
fi

UI_TARGET="-"
UI_PHASE="Boot"
UI_ACTION="Initializing..."
UI_RESULT="Pending"
UI_PROGRESS="0/0"
UI_SPINNER=0

render_dashboard() {
    [ "$IS_TTY" -eq 1 ] || return 0
    local spin_chars=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local spin="${spin_chars[$UI_SPINNER]}"
    UI_SPINNER=$(((UI_SPINNER + 1) % ${#spin_chars[@]}))
    clear
    echo -e "${FG_MAG}┌────────────────────────────────────────────────────────┐${RST}"
    echo -e "${FG_MAG}│${RST} ${FG_BLU}BDWY SYSTEM INITIALIZATION ENGINE${RST}               ${FG_MAG}│${RST}"
    echo -e "${FG_MAG}└────────────────────────────────────────────────────────┘${RST}"
    echo -e "  ${FG_DIM}Version: ${SCRIPT_VERSION}${RST}"
    echo -e "  ${FG_CYN}Target${RST}   : ${FG_GRN}${UI_TARGET}${RST}"
    echo -e "  ${FG_CYN}Phase${RST}    : ${FG_ORG}${UI_PHASE}${RST} ${FG_DIM}${spin}${RST}"
    echo -e "  ${FG_CYN}Action${RST}   : ${FG_YLW}${UI_ACTION}${RST}"
    echo -e "  ${FG_CYN}Status${RST}   : ${UI_RESULT}"
    echo -e "  ${FG_CYN}Progress${RST} : ${FG_BLU}${UI_PROGRESS}${RST}"
    echo ""
}

ui_set() {
    local key="$1"
    local value="$2"
    case "$key" in
        target) UI_TARGET="$value" ;;
        phase) UI_PHASE="$value" ;;
        action) UI_ACTION="$value" ;;
        result) UI_RESULT="$value" ;;
        progress) UI_PROGRESS="$value" ;;
    esac
    render_dashboard
}

update_status() {
    ui_set result "$1"
}

show_loading_screen() {
    [ "$IS_TTY" -eq 1 ] || return 0
    local i
    for i in $(seq 1 20); do
        UI_PHASE="Boot"
        UI_ACTION="Loading modules..."
        UI_RESULT="${FG_BLU}Starting${RST}"
        UI_PROGRESS="${i}/20"
        render_dashboard
        sleep 0.03
    done
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
    ui_set action "Running: $1"
    ui_set result "${FG_BLU}In Progress${RST}"
    if ! bash -c "$1" > "$log_file" 2>&1; then
        ui_set result "${FG_RED}Failed${RST}"
        echo -e "\n${FG_RED}!!! ERROR DETECTED !!!${RST}"
        tail -n 20 "$log_file"
        exit 1
    fi
    ui_set result "${FG_GRN}Completed${RST}"
}

exec_live_fn() {
    local fn_name="$1"
    local log_file="/tmp/updater_last.log"
    ui_set action "Running: $fn_name"
    ui_set result "${FG_BLU}In Progress${RST}"
    if ! "$fn_name" > "$log_file" 2>&1; then
        ui_set result "${FG_RED}Failed${RST}"
        echo -e "\n${FG_RED}!!! ERROR DETECTED !!!${RST}"
        tail -n 20 "$log_file"
        exit 1
    fi
    ui_set result "${FG_GRN}Completed${RST}"
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
    local ostype
    ostype="$(pct config "$ctid" 2>/dev/null | awk -F': ' '/^ostype:/{print $2}' | tr -d '\r' | xargs)"
    case "$ostype" in
        alpine) echo "apk"; return 0 ;;
        debian|ubuntu|devuan) echo "apt"; return 0 ;;
    esac

    pct exec "$ctid" -- sh -lc '
if command -v apt-get >/dev/null 2>&1; then echo apt; exit 0; fi
if command -v apk >/dev/null 2>&1; then echo apk; exit 0; fi
echo unknown
' 2>/dev/null | tr -d '\r' | tail -n1 | xargs
}

ensure_line_in_file() {
    local line="$1"
    local file="$2"
    touch "$file"
    grep -Fqx "$line" "$file" || echo "$line" >> "$file"
}

install_starship_host() {
    if command -v starship >/dev/null 2>&1; then
        return 0
    fi
    apt-get install -y starship >/dev/null 2>&1 || {
        curl -fsSL https://starship.rs/install.sh | sh -s -- -y >/dev/null 2>&1
    }
}

configure_starship_host() {
    mkdir -p /root/.config
    cat > /root/.config/starship.toml <<EOF
${STARSHIP_TOML_CONTENT}
EOF
    ensure_line_in_file 'eval "$(starship init bash)"' /root/.bashrc
    ensure_line_in_file 'eval "$(starship init zsh)"' /root/.zshrc
}

configure_starship_container() {
    local ctid="$1"
    pct exec "$ctid" -- sh -lc "
mkdir -p /root/.config
cat > /root/.config/starship.toml <<'EOF'
${STARSHIP_TOML_CONTENT}
EOF
touch /root/.bashrc /root/.zshrc
grep -Fqx 'eval \"\$(starship init bash)\"' /root/.bashrc || echo 'eval \"\$(starship init bash)\"' >> /root/.bashrc
grep -Fqx 'eval \"\$(starship init zsh)\"' /root/.zshrc || echo 'eval \"\$(starship init zsh)\"' >> /root/.zshrc
"
}

install_starship_container() {
    local ctid="$1"
    local pkg_mgr="$2"
    case "$pkg_mgr" in
        apt)
            exec_live "pct exec $ctid -- sh -lc '
if command -v starship >/dev/null 2>&1; then exit 0; fi
if apt-get update -o Acquire::ForceIPv4=true -o Acquire::http::Timeout=5 && apt-get install -y starship; then exit 0; fi
if command -v curl >/dev/null 2>&1; then curl -fsSL https://starship.rs/install.sh | sh -s -- -y && exit 0; fi
if command -v wget >/dev/null 2>&1; then wget -qO- https://starship.rs/install.sh | sh -s -- -y && exit 0; fi
apt-get install -y curl ca-certificates && curl -fsSL https://starship.rs/install.sh | sh -s -- -y
'"
            ;;
        apk)
            exec_live "pct exec $ctid -- sh -lc '
if command -v starship >/dev/null 2>&1; then exit 0; fi

ARCH=\"\$(uname -m)\"
case \"\$ARCH\" in
  x86_64) STAR_ARCH=\"x86_64-unknown-linux-musl\" ;;
  aarch64) STAR_ARCH=\"aarch64-unknown-linux-musl\" ;;
  *) STAR_ARCH=\"\" ;;
esac

if [ -n \"\$STAR_ARCH\" ]; then
  TMP=\"\$(mktemp -d)\"
  URL=\"https://github.com/starship/starship/releases/latest/download/starship-\${STAR_ARCH}.tar.gz\"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL \"\$URL\" -o \"\$TMP/starship.tgz\" || true
  elif command -v wget >/dev/null 2>&1; then
    wget -qO \"\$TMP/starship.tgz\" \"\$URL\" || true
  fi
  if [ -s \"\$TMP/starship.tgz\" ] && tar -xzf \"\$TMP/starship.tgz\" -C \"\$TMP\" && [ -f \"\$TMP/starship\" ]; then
    install -m 0755 \"\$TMP/starship\" /usr/local/bin/starship
    rm -rf \"\$TMP\"
    exit 0
  fi
  rm -rf \"\$TMP\"
fi

if apk add --no-cache starship; then exit 0; fi
if command -v curl >/dev/null 2>&1; then curl -fsSL https://starship.rs/install.sh | sh -s -- -y && exit 0; fi
if command -v wget >/dev/null 2>&1; then wget -qO- https://starship.rs/install.sh | sh -s -- -y && exit 0; fi
apk add --no-cache curl ca-certificates && curl -fsSL https://starship.rs/install.sh | sh -s -- -y
'"
            ;;
        *)
            return 1
            ;;
    esac
    configure_starship_container "$ctid"
    return 0
}

is_container_running() {
    local ctid="$1"
    pct status "$ctid" 2>/dev/null | awk '{print $2}' | grep -qx "running"
}

# --- MAIN EXECUTION ---
show_loading_screen
render_dashboard

# 1. Setup
ui_set phase "INIT"
ui_set action "Anchoring system binaries..."
require_cmd apt-get
require_cmd awk
require_cmd mktemp
require_cmd curl
mkdir -p /usr/local/bin /etc/cron.weekly
curl -fsSL "$GITHUB_RAW_URL" -o "$INSTALL_PATH" 2>/dev/null || true
chmod +x "$INSTALL_PATH"
ui_set phase "SHELL"
ui_set action "Installing Starship on host..."
exec_live_fn install_starship_host
exec_live_fn configure_starship_host
update_status "${FG_GRN}✓ Host Starship Ready${RST}"

# 2. Target Resolution
targets=("pve-host-node")
if command -v pct >/dev/null 2>&1; then
    while read -r vmid; do
        [ -n "$vmid" ] || continue
        if is_container_running "$vmid"; then
            targets+=("$vmid")
        fi
    done < <(pct list | awk 'NR>1 {print $1}')
fi

# 3. Processing Loop
total_targets="${#targets[@]}"
target_index=0
for target in "${targets[@]}"; do
    target_index=$((target_index + 1))
    ui_set target "$target"
    ui_set progress "${target_index}/${total_targets}"

    if [ "$target" != "pve-host-node" ] && ! is_container_running "$target"; then
        update_status "${FG_YLW}⚠ CT ${target} is stopped; skipping${RST}"
        continue
    fi
    
    # Source normalization to prevent duplicate repository entries.
    ui_set phase "APT"
    ui_set action "Normalizing APT source definitions..."
    if [ "$target" == "pve-host-node" ]; then
        exec_live_fn enforce_proxmox_repo_policy
        exec_live_fn normalize_apt_sources
    fi
    update_status "${FG_GRN}✓ APT Sources Normalized${RST}"

    # Update Repos
    ui_set phase "REPO"
    ui_set action "Syncing repositories..."
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
        ui_set phase "SHELL"
        ui_set action "Installing Starship in CT ${target}..."
        if install_starship_container "$target" "$pkg_mgr"; then
            update_status "${FG_GRN}✓ CT ${target} Starship Ready${RST}"
        else
            update_status "${FG_RED}✗ CT ${target} Starship install failed${RST}"
            continue
        fi
    fi
    update_status "${FG_GRN}✓ Repository Synced${RST}"

    # Upgrade
    ui_set phase "UPGR"
    ui_set action "Upgrading packages..."
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
    ui_set phase "WASH"
    ui_set action "Cleaning up space..."
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

ui_set phase "DONE"
ui_set action "Optimization complete."
ui_set result "${FG_GRN}⚡ All Targets Updated${RST}"
if [ "$IS_TTY" -ne 1 ]; then
    echo -e "\n${FG_GRN}⚡ Optimization Complete.${RST}"
fi
}
