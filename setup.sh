#!/bin/sh

cd ~ || exit  # makes sure that the symlinks are shown as relative to ~ with ls -la

# make the needed symlinks if they don't exist
for file in .zshrc .inputrc; do
    [ ! -L "$file" ] && ln -sfv dotfiles/sh/"$file" "$file"
done

for file in .gitconfig .gitignore_global; do
    [ ! -L "$file" ] && ln -sfv dotfiles/git/"$file" "$file"
done

# install homebrew and all brew packages
[ ! -f /usr/local/bin/brew ] \
    && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" \
    && brew tap homebrew/bundle \
    && { brew bundle install --file=~/dotfiles/brew/Brewfile;
        /usr/local/opt/fzf/install; }

# the rest are on purpose as absolute links and not relative from ~

#[ ! -L '/Library/Keyboard Layouts/Finner.keylayout' ] \
#    && sudo ln -sfv ~/dotfiles/keylayouts/finner/Finner.keylayout '/Library/Keyboard Layouts/Finner.keylayout'

[ ! -L ~/.config/karabiner ] \
    && rm -rf ~/.config/karabiner && ln -sv ~/dotfiles/karabiner ~/.config/karabiner

# Remove delay from Dock.
# https://apple.stackexchange.com/a/70598/321512
defaults write com.apple.dock autohide-delay -int 0
defaults write com.apple.dock autohide-time-modifier -int 0
killall Dock

# Disable mouse acceleration
# (also needs https://downloads.steelseriescdn.com/drivers/tools/steelseries-exactmouse-tool.dmg)
# https://apple.stackexchange.com/a/151552/321512
defaults write .GlobalPreferences com.apple.mouse.scaling -1

# Disable holding key for special character popup, needs logging out to take effect.
# https://apple.stackexchange.com/a/332770/321512
defaults write -g ApplePressAndHoldEnabled -bool false