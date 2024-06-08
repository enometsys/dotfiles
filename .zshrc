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

# ------ Colors
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ip='ip -color=auto'
alias ls='ls --color=auto'
export LESS='-R --use-color -Dd+r$Du+b'
LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.avif=01;35:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.swp=00;90:*.tmp=00;90:*.dpkg-dist=00;90:*.dpkg-old=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:';
export LS_COLORS

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
  export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"
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
