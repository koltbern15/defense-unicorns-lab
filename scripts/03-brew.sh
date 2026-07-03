#!/usr/bin/env bash
set -e
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  echo "brew already installed"
else
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>&1 | tail -5
fi
grep -q 'linuxbrew.*shellenv' ~/.profile 2>/dev/null || echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew --version | head -1
echo BREW_DONE
