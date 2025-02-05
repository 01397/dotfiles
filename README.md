# Dotfiles

Dotfiles for my personal Mac. No installation script.

## Tools

Homebrew is out of scope for this repository.

## Installation

### Prerequisites

1. Clone the repository.

Xcode Command Line Tools will be installed when git is run for the first time.

```zsh
# Clone repo
git clone https://github.com/01397/dotfiles.git
cd dotfiles
chmod u+x scripts/*.sh
```

2. Modify the `Brewfile` to your needs.
3. `./scripts/apply.sh`

## Maintenance

### Update Brewfile

```zsh
brew bundle dump --formula --cask --tap --mas --force
```
