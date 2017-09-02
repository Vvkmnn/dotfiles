# iTerm Integration
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# These affect the bash shell; I intend to use Zsh, which makes most of these irrelevent.
#TODO: start exporting some of these ones to .zprofile as necessary

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
    shopt -s "$option" 2> /dev/null;
done;

# Add tab completion for many Bash commands
if which brew > /dev/null && [ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]; then
    source "$(brew --prefix)/share/bash-completion/bash_completion";
elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion;
fi;

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null && [ -f /usr/local/etc/bash_completion.d/git-completion.bash ]; then
    complete -o default -o nospace -F _git g;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults;

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall;
export PATH=~/Applications/bin:/Users/vivek.menon/Applications/bin:/Users/vivek.menon/.themekit:/Users/vivek.menon/.themekit:/Users/vivek.menon/.themekit:/Users/vivek.menon/.themekit:/Users/vivek.menon/.themekit:/Users/vivek.menon/Applications/bin:/Users/vivek.menon/.themekit:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# added by Anaconda3 4.2.0 installer
export PATH="/Users/vivek.menon/anaconda/bin:$PATH"

# added by Anaconda3 4.2.0 installer
export PATH="/Users/vivek.menon/Code/anaconda3/bin:$PATH"

# added by Anaconda3 4.2.0 installer
export PATH="/Users/vivek.menon/anaconda3/bin:$PATH"

# added by Anaconda3 4.4.0 installer
export PATH="/Users/v/.anaconda/bin:$PATH"
