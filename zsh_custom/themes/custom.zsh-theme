PROMPT=$'%{$fg[red]%}%c%{$reset_color%} %{$fg[blue]%}$(virtualenv_info)%{$reset_color%}% $(git_prompt_info)\
%{$fg[blue]%}->%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}✘%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}✔%{$fg[green]%}"

ZSH_THEME_GIT_PROMPT_STASHED=" %{$fg[blue]%}↯%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %{$fg[cyan]%}?%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE=" %{$fg[green]%}↑%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE=" %{$fg[red]%}↓%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE=" %{$fg[yellow]%}↕%{$fg[green]%}"
