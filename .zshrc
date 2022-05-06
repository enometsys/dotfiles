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
# Configure autocomplete
zstyle :compinstall filename $HOME/.zshrc
autoload -Uz compinit && compinit

# ------ Syntax Highlighting
zsh_syntax_highlighting_path="/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
if [ -f "$zsh_syntax_highlighting_path" ]; then 
  source "$zsh_syntax_highlighting_path"
fi

# ------ Colors
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ip='ip -color=auto'
alias ls='ls --color=auto'
export LESS='-R --use-color -Dd+r$Du+b'

# ------ Local Binaries
# add local bin in path
if [[ ! "$PATH" == *$USER/.local/bin* ]]; then
  export PATH="${PATH:+${PATH}:}$HOME/.local/bin"
fi

# ------ Editor
# Use vim as default editor
if type vim  > /dev/null; then                                                                                                                                                  
  export EDITOR=vim
  export VISUAL=vim
fi

# Use nvim over Vim
if type nvim  > /dev/null; then                                                                                                                                                  
  alias vim="nvim"                                                                                                                                                               
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
  export NNN_PLUG='b:bookmarks;j:autojump;p:preview-tui;i:imgview;c:fzcd;o:fzopen;e:gpge;d:gpgd;n:nmount;m:mtpmount'

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

if type jump  > /dev/null; then
  eval "$(jump shell zsh)"
fi

# ------ Filter
if [ -f ~/.fzf.zsh ]; then 
  # set FZF default command
  export FZF_DEFAULT_COMMAND='fd --hidden --type f --type l --exclude ".git"'
  
  # for ubuntu, fd is packaged as fdfind
  if type fdfind  > /dev/null; then
    alias fd="fdfind"
    export FZF_DEFAULT_COMMAND='fdfind --hidden --type f --type l --exclude ".git"'
  fi

  # enable fzf
  source ~/.fzf.zsh

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
  gpgconf --launch gpg-agent

  # Although all GnuPG components try to start the gpg-agent as needed, 
  # this is not possible for the ssh support because ssh does not know about it. 
  # Thus if no GnuPG tool which accesses the agent has been run, 
  # there is no guarantee that ssh is able to use gpg-agent for authentication
  # below is run to start gpg-agent so as to make ssh support possible if
  # ssh features are invoked before any gpg-agent-needed ops are run (e.g. immediateley after reboot)
  echo UPDATESTARTUPTTY | gpg-connect-agent > /dev/null
fi

# ------ Environment loader (development)
if type direnv  > /dev/null; then
  eval "$(direnv hook zsh)"
fi
asdf_path="/opt/asdf-vm/asdf.sh"
if [ -f "$asdf_path" ]; then
  . "$asdf_path"
fi

# ------ Prompt
if type starship  > /dev/null; then
  eval "$(starship init zsh)"
fi
source "${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc"
