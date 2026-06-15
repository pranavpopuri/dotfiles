#!/usr/bin/env bash
# macos.sh — apply preferred macOS system defaults.
# Run with: bash macos.sh
# Some settings require logout / restart of the affected app to take effect.

set -euo pipefail

# Ask for sudo upfront and keep it alive for the duration of the script.
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# Keyboard                                                                    #
###############################################################################

# Fastest key repeat / shortest initial delay (lower = faster).
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold accent popup so keys repeat in vim/helix/etc.
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Full keyboard access — Tab moves between all controls, not just text boxes.
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Disable "smart" substitutions that break code / terminals.
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Keep auto-capitalization and period-on-double-space (matches current setup).
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool true
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool true

###############################################################################
# Trackpad & mouse                                                            #
###############################################################################

# Tap to click.
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Disable two-finger swipe between pages in browsers/Finder (matches current).
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool false

###############################################################################
# Window & UI behavior                                                        #
###############################################################################

# Don't minimize on double-click of title bar.
defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool false

# Expand save and print dialogs by default.
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Disable the "Are you sure you want to open this application?" dialog.
defaults write com.apple.LaunchServices LSQuarantine -bool false

###############################################################################
# Dock                                                                        #
###############################################################################

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.4
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock tilesize -int 48

###############################################################################
# Finder                                                                      #
###############################################################################

# Show all filename extensions.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show the path and status bars.
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# Show POSIX path in window title.
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Default to column view.
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Search current folder by default instead of "This Mac".
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# No warning when changing a file extension.
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Show hidden files.
defaults write com.apple.finder AppleShowAllFiles -bool true

# Don't write .DS_Store on network or USB volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

###############################################################################
# Screenshots                                                                 #
###############################################################################

# Save screenshots to ~/Pictures/Screenshots (created if missing).
mkdir -p "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Menu bar clock                                                              #
###############################################################################

defaults write com.apple.menuextra.clock ShowAMPM -bool true
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write com.apple.menuextra.clock ShowDate -int 0

###############################################################################
# Apply                                                                       #
###############################################################################

for app in "Dock" "Finder" "SystemUIServer" "cfprefsd"; do
  killall "${app}" >/dev/null 2>&1 || true
done

echo "Done. Some changes require a logout or restart to take full effect."
