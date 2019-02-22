# Customizes the Zsh prompt

# Load colors module
autoload -U colors && colors

# HOSTNAME PATH >
export PROMPT="%{$fg[blue]%}%m%{$reset_color%} %{$fg[red]%}%/%{$reset_color%} %# "
