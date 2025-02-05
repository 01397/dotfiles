# Dotfiles

Dotfiles for my personal Mac. No installation script.

## Tools

Homebrew is out of scope for this repository.

## Installation

### Prerequisites

1. Xcode Command Line Tools and Homebrew are required.

```zsh
# Install Xcode Command Line Tools
xcode-select --install

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Clone the repository.

```zsh
# Clone repo
git clone https://github.com/01397/dotfiles.git
cd dotfiles
chmod u+x scripts/*.sh
```

3. Modify the `Brewfile` to your needs.

### Apply Symlinks

```zsh
# Apply symlinks
./scripts/apply.sh
```

## Maintenance

### Update Brewfile

```zsh
brew bundle dump --formula --cask --tap --mas --force
```
