#!/bin/zsh

# Change to the directory of the script
cd "$(dirname "$0")"
REPO_HOME=$(pwd)/home

# Create symbolic links
ln -sfn $REPO_HOME/.config ~/.config
ln -sfn $REPO_HOME/.zshenv ~/.zshenv
ln -sfn $REPO_HOME/.mdefaults ~/.mdefaults

# Install Homebrew
brew bundle install --file=$(pwd)/Brewfile


