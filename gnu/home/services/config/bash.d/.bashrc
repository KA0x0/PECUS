#!/usr/bin/env bash
set -euo pipefail

### This file exist because some bash code can't be passed directly to bash-services yet
### Aliases, Environment Variable goes in home.scm
### Everything else goes here
 
shopt -s autocd cdspell checkwinsize cmdhist expand_aliases histappend hostcomplete progcomp_alias
stty -ixon # Disable ctrl-s and ctrl-q

uptime
