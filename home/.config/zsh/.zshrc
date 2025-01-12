# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

# sheldon
# This must be sourced before p10k instant prompt.
eval "$(${HOMEBREW_PREFIX}/bin/sheldon source)"

# Powerlevel10k instant
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/p10k.zsh" ]]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/p10k.zsh"
fi

# play sound when command is done (~/.config/zsh/donesound.zsh)
if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/donesound.zsh" ]]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/donesound.zsh"
fi

# mise
eval "$(${HOMEBREW_PREFIX}/bin/mise activate zsh)"

# lsd
alias ls='lsd'

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
