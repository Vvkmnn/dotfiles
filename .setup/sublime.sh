brew cask install sublime-text-dev
ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ~/bin/subl
rm ${HOME}/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings
ln -s ~/.sublime/Preferences.sublime-settings /Users/${HOME}/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings

