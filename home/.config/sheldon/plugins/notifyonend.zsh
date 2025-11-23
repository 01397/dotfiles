# This script adds a sound effect to the terminal when a command finishes.

# preexec function
done_sound_preexec() {
  # set timer
  timer=${timer:-$SECONDS}
  full_command=$1
}

# precmd function
done_sound_precmd() {
  # play sound if timer is set
  if [[ -n $timer ]]; then
    # get elapsed time
    elapsed=$((SECONDS - timer))
    # unset timer
    unset timer
    # skip the command is included in the list. These commands are usually interactive and finished manually: vim, less, pico, nano, code, top, htop, `q chat`.
    first_command=$(echo "$1" | awk '{print $1}')
    if [[ $first_command =~ ^(vim|less|pico|nano|code|top|htop|man)$ || $full_command == "q chat" ]]; then
      return
    fi
    # play sound if elapsed time is greater than 5 seconds
    if (( elapsed > 2 )); then
      body="\`${full_command}\`"
      title="Command completed"
      subtitle="in $TERM_PROGRAM at $(basename $PWD)"
      osascript -e "display notification \"$body\" with title \"$title\" subtitle \"$subtitle\" sound name \"Ping\""
    fi
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec done_sound_preexec
add-zsh-hook precmd done_sound_precmd
