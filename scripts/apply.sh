#!/bin/zsh

# Change to the directory of the script
cd "$(dirname "$0")"
cd ../
REPO_HOME=$(pwd)/home

# Create symbolic links
ln -sfn $REPO_HOME/.config ~/.config
ln -sfn $REPO_HOME/.zshenv ~/.zshenv
ln -sfn $REPO_HOME/.mdefaults ~/.mdefaults

# Enable TouchID for sudo
if [[ -e /etc/pam.d/sudo_local ]]; then
    echo "✔ TouchID for sudo already enabled"
else
    sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
    sudo sed -i '' 's/#auth/auth/' /etc/pam.d/sudo_local
    echo "✔ TouchID unlock enabled"
fi

# Install Xcode Command Line Tools
if [[ $(xcode-select -p) == "/Library/Developer/CommandLineTools" ]]; then
    echo "✔ Xcode Command Line Tools already installed"
else
    xcode-select --install
    echo "✔ Xcode Command Line Tools installed"
fi

# Install Homebrew
if [[ -x "$(command -v brew)" ]]; then
    echo "✔ Homebrew already installed"
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "✔ Homebrew installed"
fi

# Install formulae, casks, and apps
if brew bundle check --file=./Brewfile &>/dev/null; then
  echo "✔ All Homebrew dependencies are satisfied"
else
  brew bundle install --file=./Brewfile
  echo "✔ Homebrew dependencies installed"
fi

