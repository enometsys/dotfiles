#------------------------------
# History
#------------------------------
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

#------------------------------
# Keybindings
#------------------------------
# Enforce vi keybindings
bindkey -v
bindkey '^R' history-incremental-search-backward

#------------------------------
# Autocomplete
#------------------------------
# Configure autocomplete
zstyle :compinstall filename $HOME/.zshrc
autoload -Uz compinit && compinit

#------------------------------
# Binaries
#------------------------------
# add local bin in path
if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

#------------------------------
# n/vim
#------------------------------
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

#------------------------------
# jump
#------------------------------
if type jump  > /dev/null; then
  eval "$(jump shell zsh)"
fi

#------------------------------
# nnn
#------------------------------
if type nnn  > /dev/null; then
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

#------------------------------
# fzf
#------------------------------
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

#------------------------------
# xclip
#------------------------------
if type xclip  > /dev/null; then
	alias xclip="xclip -selection clipboard"
fi

#-----------------------------
# gpg
#-----------------------------
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

#------------------------------
# yarn
#------------------------------
# add global yarn bins in path
if type yarn  > /dev/null; then
	export PATH=$PATH:`yarn global bin`
fi

#------------------------------
# deno
#------------------------------
# add deno bin in path
if [ -d "$HOME/.deno/bin" ]; then
  export PATH="$HOME/.deno/bin:$PATH"
fi

#------------------------------
# golang
#------------------------------
# add golang bins in path
if [ -d "$HOME/go/bin" ]; then
  export PATH="$HOME/go/bin:$PATH"
fi

#------------------------------
# rust
#------------------------------
if [ -f "$HOME/.cargo/env" ]; then 
  . "$HOME/.cargo/env"
fi

#------------------------------
# android
#------------------------------
# configure androi-studio 
if type android-studio  > /dev/null; then
  # fix for https://issuetracker.google.com/issues/36975466
  export _JAVA_AWT_WM_NONREPARENTING=1
  # alias android-studio="_JAVA_AWT_WM_NONREPARENTING=1 android-studio"

  # for capacitor hybrid runtime
  CAPACITOR_ANDROID_STUDIO_PATH="/usr/bin/android-studio"
fi

#-----------------------------
# antigen
#-----------------------------
# configure antigen
if [ -f $HOME/.antigen.zsh ]; then
  source $HOME/.antigen.zsh
  export NVM_LAZY_LOAD=true
  export NVM_NO_USE=true
  export NVM_AUTO_USE=true
  antigen bundle lukechilds/zsh-nvm
  antigen bundle zsh-users/zsh-syntax-highlighting
  antigen apply
fi

#-----------------------------
# Dircolors
#-----------------------------
LS_COLORS='rs=0:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32:';
export LS_COLORS

#------------------------------
# Prompt
#------------------------------
# print git info (if in git dir)
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:*' unstagedstr '?'
zstyle ':vcs_info:git:*' formats '%F{magenta} %b %F{red}%c%u%f '

build_prompt() {
  # print username@hostname if in ssh
  [[ "$SSH_CLIENT" ]] && echo -n "%F{yellow}%n%f at %F{green}%m%f "

  # print username if in su mode
  echo -n "%(!.%F{yellow}%n%f .)"

  # print last directory in working directory
  echo -n "%B%F{240}%1~%f%b "

  # print git info
  echo -n "${vcs_info_msg_0_}"

  # print nodejs/javascript project info
  if [[ -f package.json ]]; then
    # print package version (if in directory with package.json)
    local version
    version="$(cat package.json | jq -r '.version // ""')"
    [[ -n $version ]] && echo -n "📦 %B%F{red}v$version%f%b "      

    # print nodejs version (if loaded)
    if [[ -x "$(command -v node)" ]]; then
      echo -n "%B%F{green}⬢ v$(node --version | sed -e 's/v//')%f%b "
    fi
  fi

  # print the "prompt" symbol on the next line
  echo -n "\n"
  echo -n "%1(j.%F{blue}✦%f.)"
  echo -n "%(?.%F{green}➜.%F{red}➜%f) "
}

PROMPT='$(build_prompt)'
