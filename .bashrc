#!/bin/bash
export GNUPGHOME=~/.var/gnupg
export MAIN_SSH_KEY=~/.ssh/id_ed25519_sk
export BASHRC=~/.bashrc

export WINEPREFIX=${HOME}/Programs/winedefault
export HISTFILE="~/.local/.bash_history"


function prompt_timer_start {
    PROMPT_TIMER=${PROMPT_TIMER:-`date +%s.%3N`}
}

function prompt_timer_stop {
    local EXIT="$?"
    local NOW=`date +%s.%3N`
    local ELAPSED=$(bc <<< "$NOW - $PROMPT_TIMER")

    unset PROMPT_TIMER

    local T=${ELAPSED%.*}
    local AFTER_COMMA=${ELAPSED##*.}
    local D=$((T/60/60/24))
    local H=$((T/60/60%24))
    local M=$((T/60%60))
    local S=$((T%60))

    local TIMER_SHOW=
    [[ $D > 0 ]] && TIMER_SHOW=${TIMER_SHOW}$(printf '%dd ' $D)
    [[ $H > 0 ]] && TIMER_SHOW=${TIMER_SHOW}$(printf '%dh ' $H)
    [[ $M > 0 ]] && TIMER_SHOW=${TIMER_SHOW}$(printf '%dm ' $M)
    TIMER_SHOW=${TIMER_SHOW}$(printf "%d.${AFTER_COMMA}s" $S)

    PS1="\e[0m\n"

    if [ $EXIT != 0 ]; then
        PS1+="\e[1;31m✘ ${EXIT}"
    else
        PS1+="\e[1;32m✔ "
    fi

    #PS1+="\e[0;32m `date +%H:%M`"

    if [ -n "$VIRTUAL_ENV_PROMPT" ]; then
        PS1+=" \e[1;33m${VIRTUAL_ENV_PROMPT}"
    fi

    local PSCHAR="▶"
    if [ $(id -u) -eq 0 ]; then
        PS1+=" \e[1;31m\u@\H "
        PSCHAR="\[\e[1;31m\]#\[\e[0m\]"
    else
        PS1+=" \e[1;32m\u@\H "
    fi
    PS1+="\e[1;33m\w" # working directory


    PS1+=" \e[0;34m${TIMER_SHOW} "
    PS1+=" \[\e[0m\n\]${PSCHAR} "
}

trap 'echo -ne "\033]0;$USER@$HOSTNAME:$PWD\a"; prompt_timer_start "$BASH_COMMAND (`date +%H:%M:%S`)"' DEBUG

PROMPT_COMMAND=prompt_timer_stop

[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion

alias ls='ls --color=auto'
alias ll='ls -la'
alias l.='ls -d .* --color=auto'

alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'
alias rm='rm -I --preserve-root'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
alias ports='sudo netstat -tulanp'
alias wget="wget -c"
alias grep='grep --color=auto'
alias mkdir='mkdir -pv'
alias diff='colordiff'
alias sudosu='sudo -i bash --rcfidle ~/.bashrc'

ssh() {
    PUB_KEY=$(cat $MAIN_SSH_KEY)
    RC=$(cat $BASHRC | base64 -w0)
    /usr/bin/ssh -t $@ "echo && mkdir -p .ssh && echo $PUB_KEY > .ssh/authorized_keys && echo $RC | base64 -d > .bashrc && bash -l"
}

sudo() {
    if [[ $@ == "su" ]]; then
        command sudo -i bash --rcfile ~/.bashrc
    else
        command sudo "$@"
    fi
}

bind '\C-p:history-search-backward'
bind '\C-n":history-search-forward'
bind '\C-H":backward-kill-word'

