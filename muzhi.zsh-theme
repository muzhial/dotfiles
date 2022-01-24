#function prompt_char {
#    git branch >/dev/null 2>/dev/null && echo '±' && return
#    hg root >/dev/null 2>/dev/null && echo 'Hg' && return
#    echo '○'
#}

function prompt_char {
    echo '%%'
}
function virtualenv_info {
    [ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`') '
}

PROMPT='
%{$fg[magenta]%}%n@%m%{$reset_color%}%{$fg[yellow]%}:)%{$reset_color%}%{$fg_bold[green]%}%~%{$reset_color%}$(git_prompt_info)
$(virtualenv_info)$(prompt_char) '

ZSH_THEME_GIT_PROMPT_PREFIX="(%{$fg[cyan]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%})"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}*"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""
