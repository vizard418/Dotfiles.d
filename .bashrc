# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    PROMPT_COMMAND='PS1_CMD1=$(__git_ps1 "(%s branch)")'
    PS1='[\[\e[1;32m\]\u@\e[1;33m\]\h\[\e[0m\]]:\[\e[1;34m\]\w\n\[\e[0m\]${PS1_CMD1}\$ '
else
    PS1='\u@\h:\w\$ '
fi
unset color_prompt

# Some more aliases
alias ll="ls -lhF"
alias la="ls -aF"
alias lla="ls -lAhF"

alias :q="exit"

# History configuration
HISTCONTROL=ignoreboth        # ignore duplicates and lines starting with space
shopt -s histappend           # append to history file instead of overwriting
HISTSIZE=1000
HISTFILESIZE=2000

# Enable bash completion if available
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Update window size after each command
shopt -s checkwinsize

# Clear CDPATH to avoid unexpected behavior with 'cd'
unset CDPATH

# Load user-defined aliases if present
if [ -f ~/.bash_profile ]; then
    . ~/.bash_profile
fi
