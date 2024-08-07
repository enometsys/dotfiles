# ------ Package manager (homebrew)
brewbinpath="/opt/homebrew/bin/brew"
if [ -f "$brewbinpath" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
if type brew  > /dev/null; then
  completions_path="/opt/homebrew/share/zsh/site-functions"
  if [ -d "$completions_path" ]; then
    fpath=($completions_path $fpath)
    autoload -Uz compinit && compinit
  fi
fi

# ------ Locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# ------ history
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# add timestamp and elapsed time in history
# setopt EXTENDED_HISTORY
# share history across multiple zsh sessions
# setopt SHARE_HISTORY
# append to history
# setopt APPEND_HISTORY
# adds commands as they are typed, not at shell exit
setopt INC_APPEND_HISTORY
# expand !! into the last command but don't 
# run right away so that it can be verified
setopt HISTVERIFY

# ------ Keybindings
# Enforce vi keybindings
bindkey -v
bindkey '^R' history-incremental-search-backward

# ------ Autocomplete
local_completion_path="$HOME/.zsh/completions"
if [ -d "$local_completion_path" ]; then
  fpath=($local_completion_path $fpath)
fi
# Configure autocomplete
zstyle :compinstall filename $HOME/.zshrc
autoload -Uz compinit && compinit

# ------ Syntax Highlighting
# zsh_syntax_highlighting_path="/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
zsh_syntax_highlighting_path="/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
if [ -f "$zsh_syntax_highlighting_path" ]; then 
  source "$zsh_syntax_highlighting_path"
fi

# ------ Local Binaries
# add local bin in path
if [[ ! "$PATH" == *$USER/.local/bin* ]]; then
  export PATH="${PATH:+${PATH}:}$HOME/.local/bin"
fi

# ------ Remote
# fix for terminal emulators
alias ssh='TERM="xterm-256color" ssh'

# ------ Editor
# Use vim as default editor
if type vim  > /dev/null; then                                                                                                                                                  
  export EDITOR=vim
  export VISUAL=vim
fi

# Use nvim over Vim
if type nvim  > /dev/null; then                                                                                                                                                  
  export EDITOR=nvim
  export VISUAL=nvim
fi

# ------ Navigation
if type nnn  > /dev/null; then
  # TODO: autodownload default nnn plugins if not exist

  # hidden files on top
  export LC_COLLATE="C"

  # bin opts
  # -c 8-color scheme
  # -E use $EDITOR for undetached edits
  export NNN_OPTS="cE"

  # bookmarks
  export NNN_BMS="d:$HOME/Documents;D:$HOME/Downloads;g:/run/user/$UID/gvfs"

  # file opener
  export NNN_OPENER="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/plugins/nuke"

  # use desktop trash
  # 1 == trash-cli
  # 2 == gio trash
  export NNN_TRASH=2
  
  # FIFO to write hovered file path to
  # - used by previewer plugins
  export NNN_FIFO='/tmp/nnn.fifo'

  # plugins
  export NNN_PLUG='b:bookmarks;j:autojump;p:preview-tui;i:imgview;f:fzplug;c:fzcd;o:fzopen;e:gpge;d:gpgd;n:nmount;m:mtpmount'

  function n() {
    # Block nesting of nnn in subshells
    if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
      echo "nnn is already running"
      return
    fi

    # The default behaviour is to cd on quit (nnn checks if NNN_TMPFILE is set)
    # To cd on quit only on ^G, remove the "export" as in:
    #     NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    nnn "$@"

    if [ -f "$NNN_TMPFILE" ]; then
      . "$NNN_TMPFILE"
      rm -f "$NNN_TMPFILE" > /dev/null
    fi
  }
fi

if type zoxide  > /dev/null; then
  eval "$(zoxide init zsh)"
fi

if type broot  > /dev/null; then
  launcherpath="$HOME/.config/broot/launcher/bash/br"
  if [ -f "$launcherpath" ]; then 
    source "$launcherpath"
  fi
fi

# ------ Filter
if type fzf  > /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
  export FZF_DEFAULT_OPTS='-m --height 50%'
  # export FZF_DEFAULT_OPTS='-m --height 50% --border'

  if [ -f "/usr/share/fzf/key-bindings.zsh" ]; then 
    source "/usr/share/fzf/key-bindings.zsh"
  fi

  if [ -f "/usr/share/fzf/completion.zsh" ]; then 
    source "/usr/share/fzf/completion.zsh"
  fi

  # fkill function
  function fkill() {
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

    if [[ ! -z "$pid" ]]; then
      echo $pid | xargs kill -9
    fi 
  }
fi

# ------ Clipboard
if type xclip  > /dev/null; then
	alias xclip="xclip -selection clipboard"
fi

# ------ Encryption
# If stdin is a terminal
if [ -t 0 ]; then
	# Set GPG_TTY so gpg-agent knows where to prompt.  See gpg-agent(1)
	export GPG_TTY="$(tty)"

  # enable ssh support
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  # gpgconf --launch gpg-agent
fi

# ------ Environment loader (development)
# asdf_path="/opt/asdf-vm/asdf.sh"
asdf_path="/opt/homebrew/opt/asdf/libexec/asdf.sh"
if [ -f "$asdf_path" ]; then
  . "$asdf_path"

  # append completions to fpath then initialise completions with ZSH's compinit
  fpath=(${ASDF_DIR}/completions $fpath)
  autoload -Uz compinit && compinit
fi

if type direnv  > /dev/null; then
  eval "$(direnv hook zsh)"

  # from https://github.com/asdf-community/asdf-direnv
  asdf_zshrc_path="${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc"
  if [ -f "$asdf_zshrc_path" ]; then
    source "$asdf_zshrc_path"
  fi
fi

# ------ Colima
if type colima > /dev/null; then
  # https://github.com/abiosoft/colima/blob/main/docs/FAQ.md
  export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
  # sudo ln -sf $HOME/.colima/default/docker.sock /var/run/docker.sock
fi

# ------ Proto
proto_dir="$HOME/.proto"
if [ -d "$proto_dir" ]; then
  export PROTO_HOME="$proto_dir"

  proto_shims="$PROTO_HOME/shims"
  case ":$PATH:" in
    *":$proto_shims:"*) ;;
    *) export PATH="$proto_shims:$PATH" ;;
  esac

  proto_bins="$PROTO_HOME/bin"
  case ":$PATH:" in
    *":$proto_bins:"*) ;;
    *) export PATH="$proto_bins:$PATH" ;;
  esac
fi

# ------ PNPM
export PNPM_HOME="/Users/metsys/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ------ Prompt
if type starship  > /dev/null; then
  eval "$(starship init zsh)"
fi
source "${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc"
