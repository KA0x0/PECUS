if [[ $- != *i* ]]
then
    # We are being invoked from a non-interactive shell.  If this
    # is an SSH session (as in "ssh host command"), source
    # /etc/profile so we get PATH and other essential variables.
    [[ -n "$SSH_CLIENT" ]] && source /etc/profile
 
    # Don't do anything else, returning a successful return code.
    return 0
fi

### This file exist because some bash code can't be passed directly to bash-services yet
### Aliases, Environment Variable goes in home.scm
### Everything else goes here
 
shopt -s autocd cdspell dirspell histappend progcomp_alias
stty -ixon # Disable ctrl-s and ctrl-q

uptime
