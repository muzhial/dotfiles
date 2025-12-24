#!/bin/bash
set -e

resolve_path() {
    local target="$1"
    if command -v realpath >/dev/null 2>&1; then
        realpath "$target"
    elif command -v python3 >/dev/null 2>&1; then
        python - <<'PY' "$target"
import os
import sys
print(os.path.realpath(sys.argv[1]))
PY
    else
        local dir
        dir=$(cd "$(dirname "$target")" && pwd)
        echo "$dir/$(basename "$target")"
    fi
}

SCRIPT_NAME=$(basename "$0")
CWD=$(pwd)
FILE_PATH=$(resolve_path "$0")
ROOT_DIR=$(dirname "$FILE_PATH")

HELP=0
SU=false
SSHD_PW=""

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [options] <command> [args...]

Commands:
  install [packages...]       Install packages and apply optional dotfile configs.
  config <targets...>         Configure dotfiles/resources (e.g. codex, cc).

Options:
  --ssh_pw <password>         Password used when configuring ssh (requires command: install ssh).
  --su                        Run installation steps with sudo.
  -h, --help                  Show this help and exit.

Examples:
  $SCRIPT_NAME install --ssh_pw xxx ssh
  $SCRIPT_NAME install zsh ssh tmux neovim
  $SCRIPT_NAME config codex cc
EOF
}

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--extension)
            EXTENSION="$2"
            shift
            shift
            ;;
        --default)
            DEFAULT=YES
            shift
            ;;
        --su)
            SU=true
            shift
            ;;
        --ssh_pw)
            SSHD_PW="$2"
            shift
            shift
            ;;
        -h|--help)
            HELP=1
            shift
            ;;
        -*|--*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

set -- "${POSITIONAL_ARGS[@]}"

COMMAND=""
if [[ $# -gt 0 ]]; then
    COMMAND=$1
    shift
fi

if [[ "$HELP" == "1" ]]; then
    usage
    exit 0
fi

if [[ -z "$COMMAND" ]]; then
    usage
    exit 1
fi

if [[ "$SU" == true ]]; then
    sudo='sudo'
else
    sudo=''
fi

APT_UPDATED=0

detect_pkg_manager() {
    if command -v apt >/dev/null 2>&1; then
        echo "apt"
    elif command -v brew >/dev/null 2>&1; then
        echo "brew"
    else
        echo "unknown"
    fi
}

check_and_install() {
    local packages=("$@")
    if [ ${#packages[@]} -eq 0 ]; then
        return 0
    fi

    local manager
    manager=$(detect_pkg_manager)

    case "$manager" in
        apt)
            if [ "$APT_UPDATED" -eq 0 ]; then
                echo "-> apt update"
                $sudo apt update
                APT_UPDATED=1
            fi
            for pkg in "${packages[@]}"; do
                if dpkg -s "$pkg" >/dev/null 2>&1; then
                    echo "-> install $pkg (already installed)"
                else
                    echo "-> install $pkg"
                    $sudo apt install -y "$pkg"
                fi
            done
            ;;
        brew)
            for pkg in "${packages[@]}"; do
                if brew list "$pkg" >/dev/null 2>&1; then
                    echo "-> install $pkg (already installed)"
                else
                    echo "-> install $pkg"
                    brew install "$pkg"
                fi
            done
            ;;
        *)
            echo "[WARN] Could not install packages automatically (no supported package manager)."
            echo "       Please install manually: ${packages[*]}"
            ;;
    esac
}

config_tmux() {
    echo "-> config tmux"
    local tmux_src="$ROOT_DIR/.tmux"
    if [ ! -d "$tmux_src" ]; then
        echo "[WARN] tmux config directory not found at $tmux_src"
        return
    fi

    cp -r "$tmux_src" "$HOME"
    (
        cd "$HOME"
        ln -s -f .tmux/.tmux.conf
    )

    local tmux_local_src="$ROOT_DIR/zoo/.tmux.conf.local"
    if [ -f "$tmux_local_src" ]; then
        cp "$tmux_local_src" "$HOME/.tmux.conf.local"
    fi
}

configure_ssh() {
    echo "-> install openssh"
    local manager
    manager=$(detect_pkg_manager)

    case "$manager" in
        apt)
            check_and_install openssh-server
            ;;
        brew)
            check_and_install openssh
            ;;
        *)
            echo "[WARN] Unable to install ssh server automatically."
            ;;
    esac

    if [ ! -f /etc/ssh/sshd_config ]; then
        echo "[WARN] sshd_config not found; skipping ssh configuration."
        return
    fi

    echo "-> config ssh"
    $sudo mkdir -p /var/run/sshd

    if [[ -n "$SSHD_PW" ]]; then
        echo "root:$SSHD_PW" | $sudo chpasswd
    fi

    $sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    $sudo sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
}

configure_zsh() {
    if ! command -v zsh >/dev/null 2>&1; then
        echo "[WARN] zsh is not installed; skipping zsh configuration."
        return
    fi

    echo "-> setting zsh as default shell"
    local zsh_path
    zsh_path=$(command -v zsh)

    if [[ -n "$sudo" ]]; then
        $sudo usermod -s "$zsh_path" "$(whoami)"
    else
        chsh -s "$zsh_path"
    fi

    echo "[INFO] Default shell changed to zsh. Log out and back in for changes to take effect."

    echo "-> adding zsh fallback to .bashrc"
    local bashrc="$HOME/.bashrc"
    if [ -f "$bashrc" ]; then
        if ! grep -q "exec zsh" "$bashrc" 2>/dev/null; then
            {
                echo ""
                echo "# Auto-start zsh if available and not already in zsh"
                echo 'if [ -x "$(command -v zsh)" ] && [ "$0" != "-zsh" ] && [ -z "$ZSH_VERSION" ]; then'
                echo '    exec zsh'
                echo 'fi'
            } >>"$bashrc"
        fi
    fi

    echo "-> installing oh-my-zsh"
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    fi

    echo "-> config pure theme in zsh"
    mkdir -p "$HOME/.zsh"
    if [ ! -d "$HOME/.zsh/pure/.git" ]; then
        rm -rf "$HOME/.zsh/pure"
        git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
    fi

    local zshrc="$HOME/.zshrc"
    if ! grep -q "# --- pure theme ---" "$zshrc" 2>/dev/null; then
        {
            echo "# --- pure theme ---"
            echo "fpath+=(\$HOME/.zsh/pure)"
            echo "autoload -U promptinit; promptinit"
            echo "prompt pure"
        } >>"$zshrc"
    fi
}

install_fzf() {
    echo "-> install fzf"
    check_and_install git
    if [ -d "$HOME/.fzf" ]; then
        rm -rf "$HOME/.fzf"
    fi
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    yes | "$HOME/.fzf/install"
}

config_codex() {
    local src="$ROOT_DIR/.llm/codex/prompts/."
    local dest_dir="$HOME/.codex"
    local dest="$dest_dir/prompts"

    if [ ! -d "$src" ]; then
        echo "[WARN] codex prompts directory not found at $src"
        return
    fi

    echo "-> config codex prompts"
    mkdir -p "$dest"
    cp -R "$src" "$dest"
}

config_claude_code() {
    local src="$ROOT_DIR/.llm/claude_code/commands/."
    local dest_dir="$HOME/.claude"
    local dest="$dest_dir/commands"

    if [ ! -d "$src" ]; then
        echo "[WARN] claude commands directory not found at $src"
        return
    fi

    echo "-> config claude commands"
    mkdir -p "$dest"
    cp -R "$src" "$dest"
}

config_cursor() {
    local src="$ROOT_DIR/.llm/cursor/rules/."
    local dest_dir="$HOME/.cursor"
    local dest="$dest_dir/rules"

    if [ ! -d "$src" ]; then
        echo "[WARN] cursor rules directory not found at $src"
        return
    fi

    echo "-> config cursor rules"
    mkdir -p "$dest"
    cp -R "$src" "$dest"
}

command_install() {
    local args=("$@")
    local base_packages=(wget curl htop zip unzip)
    check_and_install "${base_packages[@]}"

    local generic_packages=()
    for entry in "${args[@]}"; do
        case "$entry" in
            tmux)
                check_and_install tmux
                config_tmux
                ;;
            ssh)
                configure_ssh
                ;;
            zsh)
                check_and_install zsh
                configure_zsh
                ;;
            fzf)
                install_fzf
                ;;
            *)
                generic_packages+=("$entry")
                ;;
        esac
    done

    if [ "${#generic_packages[@]}" -gt 0 ]; then
        check_and_install "${generic_packages[@]}"
    fi
}

command_config() {
    local targets=("$@")
    if [ ${#targets[@]} -eq 0 ]; then
        echo "[ERROR] No config target specified."
        usage
        exit 1
    fi

    for target in "${targets[@]}"; do
        case "$target" in
            codex)
                config_codex
                ;;
            cc|claude|claude_code)
                config_claude_code
                ;;
            cursor)
                config_cursor
                ;;
            all)
                config_codex
                config_claude_code
                config_cursor
                ;;
            *)
                echo "[WARN] Unknown config target: $target"
                ;;
        esac
    done
}

case "$COMMAND" in
    install)
        command_install "$@"
        ;;
    config)
        command_config "$@"
        ;;
    *)
        echo "[ERROR] Unknown command: $COMMAND"
        usage
        exit 1
        ;;
esac
