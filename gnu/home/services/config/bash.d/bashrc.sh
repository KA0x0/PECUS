#!/usr/bin/env bash
set -euo pipefail

### This file exist because some bash code can't be passed directly to bash-services yet
### Aliases, Environment Variable goes in home.scm
### Everything else goes here

set colored-completion-prefix on
set colored-stats on
set completion-ignore-case on
set show-all-if-ambiguous on
set skip-completed-text on
 
shopt -s autocd cdspell checkwinsize cmdhist expand_aliases histappend
stty -ixon # Disable ctrl-s and ctrl-q

### BINDS
bind '"\C-p": history-search-backward'
bind '"\C-n": history-search-forward'

uptime
