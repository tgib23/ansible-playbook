autoload -U compinit
autoload -U zmv
autoload -U history-search-end
autoload -U colors

zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

compinit
colors

alias c=clear
alias cet='TZ=Europe/Budapest date'
alias egrep='egrep --color=auto'
alias eman='MANPATH=/usr/share/man:/usr/local/man:/home/y/man LANG=C jman'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias h='history -43'
alias j=jobs
alias jpdate='TZ=Asia/Tokyo date'
alias l='ls --color -FAl'
alias lf='ls --color -FA'
alias lh='ls --color -FAlh'
alias lsa='ls --color -Fld .*'
alias lsd='ls --color -Fld *(-/DN)'
alias lsd='ls --color -Fld *(.)'
alias man='LC_CTYPE=ja_JP.eucJP man'
alias nrp="RPROMPT=''"
alias rp="RPROMPT=$'%{${fg[blue]}%}[%~] %D{%Y-%m-%d} %D{%a} %D{%H:%M}%{${reset_color}%}'"
alias su='su -m'
alias ustime='TZ=PST8PDT date'
alias vi='LANG=ja_JP.eucJP vim'
alias view='LANG=ja_JP.eucJP vim -R'

alias -g E='|nkf -e'
alias -g G='|grep'
alias -g M='|more'
alias -g H='|head'
alias -g QF='--queryformat="%{n}.%{arch}\t%{v}-%{r}\t%{n}-%{v}-%{r}.%{arch}.rpm\n"'
alias -g S='|sort'
alias -g T='|tail'
alias -g L='|less'
alias -g V='|$HOME/share/vim/vim72/macros/less.sh'
alias -g W='|wc'
alias ssh-peco='ssh -A $(grep -iE "^host[[:space:]]+[^*]" ~/.ssh/config|peco|awk "{print \$2}")'

setenv() { typeset -x "${1}${1:+=}${(@)argv[2,$#]}" }
precmd() { PROMPT=$'%{%(?.${fg_bold[red]}.${bg[black]}${fg_bold[red]})%}%n@${HOST}[%h]%(!.#.)%{${reset_color}%} ' }
stw()    { echo -ne "\033]0;${1:=${HOST}} `hostname `\007" }

function ssh_screen() {
    eval server=\${$#}
    screen -t $server ssh "$@"
}
[ x$STY != x ] && alias ssh=ssh_screen

export CVS_RSH=ssh
export CVSEDITOR=vim

export ACRON=$HOME/.acron
export BLOCKSIZE=G
export CLICOLOR=yes
export EDITOR=vim
export LC_TIME=C
export JLESSCHARSET=japanese
export LSCOLORS='ExFxcxDxBxegedabagacad'
export LS_COLORS=':no=00:fi=00:di=01;34:ln=01;35:pi=01;33:so=32:bd=01;34;46:cd=01;34;43:ex=01;31:'
export MANPATH='/usr/share/man/ja:/usr/local/man/ja:/usr/share/man:/usr/local/man:/usr/X11R6/man:/home/y/man/ja:/home/y/man'
export PAGER='less'
export TERM=xterm-256color
export TMPDIR=/tmp
export WORDCHARS='*?[]~=&;!#$%^(){}<>'
export ZLS_COLORS=':no=00:fi=00:di=01;34:ln=01;35:pi=01;33:so=32:bd=01;34;46:cd=01;34;43:ex=01;31:'

export MVN_HOME=~/development/apache-maven-3.2.2
MVN_PATH=$MVN_HOME/bin
export GOROOT=/usr/local/opt/go/libexec
export GOPATH=$HOME
#export JAVA_HOME=`/System/Library/Frameworks/JavaVM.framework/Versions/A/Commands/java_home -v "1.8"`
path=( ~/.rbenv/bin ~/.rbenv/shims $HOME/{bin,sbin} /usr/local/{bin,sbin} /{bin,sbin} /usr/{bin,sbin} $JAVA_HOME/bin $MVN_PATH /Applications/play-2.2.0/ /Applications/activator-1.3.2/ $GOROOT/bin $GOPATH/bin $HOME/.packer ~/google-cloud-sdk/bin )
export PATH
fignore=(CVS)

DIRSTACKSIZE=16
HISTFILE=~/.histfile
HISTSIZE=10000
PROMPT=$'%{%(?.${fg_bold[red]}.${bg[black]}${fg_bold[red]})%}%n@${HOST%%}[%h]%(!.#.)%{${reset_color}%} '
RPROMPT=$'%{${fg[blue]}%}[%~] %D{%Y-%m-%d} %D{%a} %D{%H:%M}%{${reset_color}%}'
SAVEHIST=100000
term=xterm-256color

bindkey -e
bindkey ' ' magic-space
bindkey '^B' backward-word
bindkey '^[B' backward-char
bindkey '^F' forward-word
bindkey '^[F' forward-char
bindkey '^I' complete-word
bindkey "\e[1~" beginning-of-line
bindkey "\e[7~" beginning-of-line
bindkey "\e[2~" overwrite-mode
bindkey "\e[3~" delete-char
bindkey "\e[4~" end-of-line
bindkey "\e[8~" end-of-line

setopt   notify glob_dots correct pushd_to_home auto_list
setopt   auto_cd extended_history recexact long_list_jobs
setopt   auto_resume hist_ignore_all_dups pushd_silent no_clobber
setopt   auto_pushd pushd_minus extended_glob rcquotes mail_warning
setopt   ignore_eof prompt_subst pushd_ignore_dups hist_allow_clobber numeric_glob_sort list_types braceccl
setopt   auto_remove_slash always_last_prompt hist_ignore_space no_beep complete_in_word
setopt   share_history hist_reduce_blanks hist_no_store
unsetopt cdable_vars
unsetopt bg_nice auto_param_slash
unsetopt prompt_cr

zmodload -a zsh/stat stat
zmodload -a zsh/zprof zprof
zmodload -a zsh/zpty zpty
zmodload -ap zsh/mapfile mapfile

zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' verbose yes
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~' '*?.old' '*?.bak' '*?.pro'
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'

limit core 0
stty erase '^H' kill '^U'
typeset -U path cdpath fpath manpath
umask 022
stw

if [[ -s ~/.nvm/nvm.sh ]];
   then source ~/.nvm/nvm.sh
fi
