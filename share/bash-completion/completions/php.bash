#!/bin/bash
# . ./share/bash-completion/completions/php.bash

_phpmv() {
  COMPREPLY=()
  # local word="${COMP_WORDS[COMP_CWORD]}"
  # echo "word: '$word'"
  # echo "COMP_CWORD: '$COMP_CWORD'"
  # echo "COMP_WORDS: '$COMP_WORDS'"
  # echo "COMP_LINE: '$COMP_LINE'"
  # echo "COMP_POINT: '$COMP_POINT'"
 
 
    local words
    IFS=' ' read -r -a words <<< "${COMP_LINE[@]}"
    unset words[0]
    # unset words[$COMP_CWORD]
    # echo "COMP_LINE: '$COMP_LINE'"
    local completions=$(php commands "${words[@]}")
    # echo "completions: '$completions'"
    # COMPREPLY=( $(compgen -W "$completions" -- "${words[@]}") )
    # echo "-"
    # echo $(compgen -W "$completions" -- "${words[@]}")
    # echo "----"
    COMPREPLY=( $(compgen -W "$completions" -- "${words[@]}") )
    # echo "COMPREPLY: $COMPREPLY"
    # echo "----"
}

complete -F _phpmv php
