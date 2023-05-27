# Generated by Powerlevel10k configuration wizard on 2023-04-18 at 21:25 EDT.
# Based on romkatv/powerlevel10k/config/p10k-pure.zsh, checksum 35142.
# Wizard options: nerdfont-complete + powerline, small icons, pure, rprompt, 24h time,
# 1 line, compact, instant_prompt=verbose.
# Type `p10k configure` to generate another config.
#
# Config file for Powerlevel10k with the style of Pure (https://github.com/sindresorhus/pure).
#
# Differences from Pure:
#
#   - Git:
#     - `@c4d3ec2c` instead of something like `v1.4.0~11` when in detached HEAD state.
#     - No automatic `git fetch` (the same as in Pure with `PURE_GIT_PULL=0`).
#
# Apart from the differences listed above, the replication of Pure prompt is exact. This includes
# even the questionable parts. For example, just like in Pure, there is no indication of Git status
# being stale; prompt symbol is the same in command, visual and overwrite vi modes; when prompt
# doesn't fit on one line, it wraps around with no attempt to shorten it.
#
# If you like the general style of Pure but not particularly attached to all its quirks, type
# `p10k configure` and pick "Lean" style. This will give you slick minimalist prompt while taking
# advantage of Powerlevel10k features that aren't present in Pure.

# Temporarily change options.
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options.
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh >= 5.1 is required.
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # Prompt colors.
  local grey='242'
  local red='1'
  local yellow='3'
  local blue='4'
  local magenta='5'
  local cyan='6'
  local white='7'

  # Left prompt segments.
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    # om                        # TODO fix, custom prompt
    # context                 # user@host
    dir                       # current directory
    vcs                       # git status
    # command_execution_time  # previous command duration
    # virtualenv              # python virtual environment
    prompt_char               # prompt symbol
  )

  # Right prompt segments.
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    command_execution_time    # previous command duration
    virtualenv                # python virtual environment
    context                   # user@host
    face
    time                      # current time
  )

  # Basic style options that define the overall prompt look.
  typeset -g POWERLEVEL9K_BACKGROUND=                            # transparent background
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=  # no surrounding whitespace
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '  # separate segments with a space
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=        # no end-of-line symbol
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=           # no segment icons

  # Add an empty line before each prompt except the first. This doesn't emulate the bug
  # in Pure that makes prompt drift down whenever you use the Alt-C binding from fzf or similar.
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false

  # Magenta prompt symbol if the last command succeeded.
  # typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND='214'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=214
  # typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=76
  # Red prompt symbol if the last command failed.
  # typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND=$red
  
  # Default prompt symbol.
  # typeset -g POWERLEVEL9K_PROMPT_CHAR='ॐ'
  # typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='ॐ '
  # typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='ॐ'
  # Prompt symbol in command vi mode.

  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  # Prompt symbol in visual vi mode is the same as in command mode.
  # typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='❯'
  # Prompt symbol in replace vi mode is original char
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='❯'
  # typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='❯'
  
  # Prompt symbol in overwrite vi mode is the same as in command mode.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true

  # Grey Python Virtual Environment.
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=$grey
  # Don't show Python version.
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=false
  typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=

  # Blue current directory.
  typeset -g POWERLEVEL9K_DIR_FOREGROUND='91'

  ##################################[ dir: current directory ]##################################
  # Default current directory color.
  # If directory is too long, shorten some of its segments to the shortest possible unique
  # prefix. The shortened directory can be tab-completed to the original.
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  # Replace removed segment suffixes with this symbol.
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  # Color of the shortened directory segments.
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='91'
  # Color of the anchor directory segments. Anchor segments are never shortened. The first
  # segment is always an anchor.
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='93'
  # Display anchor directory segments in bold.
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  # Don't shorten directories that contain any of these files. They are anchors.
  # local anchor_files=(
  #   .bzr
  #   .citc
  #   .git
  #   .hg
  #   .node-version
  #   .python-version
  #   .go-version
  #   .ruby-version
  #   .lua-version
  #   .java-version
  #   .perl-version
  #   .php-version
  #   .tool-version
  #   .shorten_folder_marker
  #   .svn
  #   .terraform
  #   CVS
  #   Cargo.toml
  #   composer.json
  #   go.mod
  #   package.json
  #   stack.yaml
  # )
  # typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchor_files})"
  # If set to "first" ("last"), remove everything before the first (last) subdirectory that contains
  # files matching $POWERLEVEL9K_SHORTEN_FOLDER_MARKER. For example, when the current directory is
  # /foo/bar/git_repo/nested_git_repo/baz, prompt will display git_repo/nested_git_repo/baz (first)
  # or nested_git_repo/baz (last). This assumes that git_repo and nested_git_repo contain markers
  # and other directories don't.
  #
  # Optionally, "first" and "last" can be followed by ":<offset>" where <offset> is an integer.
  # This moves the truncation point to the right (positive offset) or to the left (negative offset)
  # relative to the marker. Plain "first" and "last" are equivalent to "first:0" and "last:0"
  # respectively.
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
  # Don't shorten this many last directory segments. They are anchors.
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  # Shorten directory if it's longer than this even if there is space for it. The value can
  # be either absolute (e.g., '80') or a percentage of terminal width (e.g, '50%'). If empty,
  # directory will be shortened only when prompt doesn't fit or when other parameters demand it
  # (see POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS and POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT below).
  # If set to `0`, directory will always be shortened to its minimum length.
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  # When `dir` segment is on the last prompt line, try to shorten it enough to leave at least this
  # many columns for typing commands.
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
  # When `dir` segment is on the last prompt line, try to shorten it enough to leave at least
  # COLUMNS * POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT * 0.01 columns for typing commands.
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50
  # If set to true, embed a hyperlink into the directory. Useful for quickly
  # opening a directory in the file manager simply by clicking the link.
  # Can also be handy when the directory is shortened, as it allows you to see
  # the full directory that was used in previous commands.
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=true

  # Enable special styling for non-writable and non-existent directories. See POWERLEVEL9K_LOCK_ICON
  # and POWERLEVEL9K_DIR_CLASSES below.
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3

  # The default icon shown next to non-writable and non-existent directories when
  # POWERLEVEL9K_DIR_SHOW_WRITABLE is set to v3.
  # typeset -g POWERLEVEL9K_LOCK_ICON='⭐'

  # POWERLEVEL9K_DIR_CLASSES allows you to specify custom icons and colors for different
  # directories. It must be an array with 3 * N elements. Each triplet consists of:
  #
  #   1. A pattern against which the current directory ($PWD) is matched. Matching is done with
  #      extended_glob option enabled.
  #   2. Directory class for the purpose of styling.
  #   3. An empty string.
  #
  # Triplets are tried in order. The first triplet whose pattern matches $PWD wins.
  #
  # If POWERLEVEL9K_DIR_SHOW_WRITABLE is set to v3, non-writable and non-existent directories
  # acquire class suffix _NOT_WRITABLE and NON_EXISTENT respectively.
  #
  # For example, given these settings:
  #
  #   typeset -g POWERLEVEL9K_DIR_CLASSES=(
  #     '~/work(|/*)'  WORK     ''
  #     '~(|/*)'       HOME     ''
  #     '*'            DEFAULT  '')
  #
  # Whenever the current directory is ~/work or a subdirectory of ~/work, it gets styled with one
  # of the following classes depending on its writability and existence: WORK, WORK_NOT_WRITABLE or
  # WORK_NON_EXISTENT.
  #
  # Simply assigning classes to directories doesn't have any visible effects. It merely gives you an
  # option to define custom colors and icons for different directory classes.
  #
  #   # Styling for WORK.
  #   typeset -g POWERLEVEL9K_DIR_WORK_VISUAL_IDENTIFIER_EXPANSION='⭐'
  #   typeset -g POWERLEVEL9K_DIR_WORK_FOREGROUND=31
  #   typeset -g POWERLEVEL9K_DIR_WORK_SHORTENED_FOREGROUND=103
  #   typeset -g POWERLEVEL9K_DIR_WORK_ANCHOR_FOREGROUND=39
  #
  #   # Styling for WORK_NOT_WRITABLE.
  #   typeset -g POWERLEVEL9K_DIR_WORK_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION='⭐'
  #   typeset -g POWERLEVEL9K_DIR_WORK_NOT_WRITABLE_FOREGROUND=31
  #   typeset -g POWERLEVEL9K_DIR_WORK_NOT_WRITABLE_SHORTENED_FOREGROUND=103
  #   typeset -g POWERLEVEL9K_DIR_WORK_NOT_WRITABLE_ANCHOR_FOREGROUND=39
  #
  #   # Styling for WORK_NON_EXISTENT.
  #   typeset -g POWERLEVEL9K_DIR_WORK_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION='⭐'
  #   typeset -g POWERLEVEL9K_DIR_WORK_NON_EXISTENT_FOREGROUND=31
  #   typeset -g POWERLEVEL9K_DIR_WORK_NON_EXISTENT_SHORTENED_FOREGROUND=103
  #   typeset -g POWERLEVEL9K_DIR_WORK_NON_EXISTENT_ANCHOR_FOREGROUND=39
  #
  # If a styling parameter isn't explicitly defined for some class, it falls back to the classless
  # parameter. For example, if POWERLEVEL9K_DIR_WORK_NOT_WRITABLE_FOREGROUND is not set, it falls
  # back to POWERLEVEL9K_DIR_FOREGROUND.
  #
  # typeset -g POWERLEVEL9K_DIR_CLASSES=()

  # Custom prefix.
  # typeset -g POWERLEVEL9K_DIR_PREFIX='%fin '


  # Context format when root: user@host. The first part white, the rest grey.
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE="%F{$white}%n%f%F{$grey}@%m%f"
  # Context format when not root: user@host. The whole thing grey.
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE="%F{$grey}%n@%m%f"
  # Don't show context unless root or in SSH.
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_CONTENT_EXPANSION=

  # Show previous command duration only if it's >= 5s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=5
  # Don't show fractional seconds. Thus, 7s rather than 7.3s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  # Duration format: 1d 2h 3m 4s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  # Yellow previous command duration.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$yellow


  # Grey Git prompt. This makes stale prompts indistinguishable from up-to-date ones.
  typeset -g POWERLEVEL9K_VCS_FOREGROUND=$cyan

  # Disable async loading indicator to make directories that aren't Git repositories
  # indistinguishable from large Git repositories without known state.
  typeset -g POWERLEVEL9K_VCS_LOADING_TEXT=

  # Don't wait for Git status even for a millisecond, so that prompt always updates
  # asynchronously when Git state changes.
  typeset -g POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS=0

  # Cyan ahead/behind arrows.
  typeset -g POWERLEVEL9K_VCS_{INCOMING,OUTGOING}_CHANGESFORMAT_FOREGROUND=$cyan
  # Don't show remote branch, current tag or stashes.
  typeset -g POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes git-untracked git-aheadbehind)
  # Don't show the branch icon.
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=
  # When in detached HEAD state, show @commit where branch normally goes.
  typeset -g POWERLEVEL9K_VCS_COMMIT_ICON='@'
  # Don't show staged, unstaged, untracked indicators.
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED}_ICON=
  # Show '*' when there are staged, unstaged or untracked files.
  typeset -g POWERLEVEL9K_VCS_DIRTY_ICON='*'
  # Show '⇣' if local branch is behind remote.
  typeset -g POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON=':⇣'
  # Show '⇡' if local branch is ahead of remote.
  typeset -g POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON=':⇡'
  # Don't show the number of commits next to the ahead/behind arrows.
  typeset -g POWERLEVEL9K_VCS_{COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=1
  # Remove space between '⇣' and '⇡' and all trailing spaces.
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${${${P9K_CONTENT/⇣* :⇡/⇣⇡}// }//:/ }'

  #####################################[ vcs: git status ]######################################
  # Branch icon. Set this parameter to '\UE0A0 ' for the popular Powerline branch icon.
  #typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=

  ## Untracked files icon. It's really a question mark, your font isn't broken.
  ## Change the value of this parameter to show a different icon.
  #typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'

  ## Formatter for Git status.
  ##
  ## Example output: master wip ⇣42⇡42 *42 merge ~42 +42 !42 ?42.
  ##
  ## You can edit the function to customize how Git status looks.
  ##
  ## VCS_STATUS_* parameters are set by gitstatus plugin. See reference:
  ## https://github.com/romkatv/gitstatus/blob/master/gitstatus.plugin.zsh.
  #function my_git_formatter() {
  #  emulate -L zsh

  #  if [[ -n $P9K_CONTENT ]]; then
  #    # If P9K_CONTENT is not empty, use it. It's either "loading" or from vcs_info (not from
  #    # gitstatus plugin). VCS_STATUS_* parameters are not available in this case.
  #    typeset -g my_git_format=$P9K_CONTENT
  #    return
  #  fi

  #  if (( $1 )); then
  #    # Styling for up-to-date Git status.
  #    local       meta='%f'     # default foreground
  #    local      clean='%76F'   # green foreground
  #    local   modified='%178F'  # yellow foreground
  #    local  untracked='%39F'   # blue foreground
  #    local conflicted='%196F'  # red foreground
  #  else
  #    # Styling for incomplete and stale Git status.
  #    local       meta='%244F'  # grey foreground
  #    local      clean='%244F'  # grey foreground
  #    local   modified='%244F'  # grey foreground
  #    local  untracked='%244F'  # grey foreground
  #    local conflicted='%244F'  # grey foreground
  #  fi

  #  local res

  #  if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
  #    local branch=${(V)VCS_STATUS_LOCAL_BRANCH}
  #    # If local branch name is at most 32 characters long, show it in full.
  #    # Otherwise show the first 12 … the last 12.
  #    # Tip: To always show local branch name in full without truncation, delete the next line.
  #    (( $#branch > 32 )) && branch[13,-13]="…"  # <-- this line
  #    res+="${clean}${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}${branch//\%/%%}"
  #  fi

  #  if [[ -n $VCS_STATUS_TAG
  #        # Show tag only if not on a branch.
  #        # Tip: To always show tag, delete the next line.
  #        && -z $VCS_STATUS_LOCAL_BRANCH  # <-- this line
  #      ]]; then
  #    local tag=${(V)VCS_STATUS_TAG}
  #    # If tag name is at most 32 characters long, show it in full.
  #    # Otherwise show the first 12 … the last 12.
  #    # Tip: To always show tag name in full without truncation, delete the next line.
  #    (( $#tag > 32 )) && tag[13,-13]="…"  # <-- this line
  #    res+="${meta}#${clean}${tag//\%/%%}"
  #  fi

  #  # Display the current Git commit if there is no branch and no tag.
  #  # Tip: To always display the current Git commit, delete the next line.
  #  [[ -z $VCS_STATUS_LOCAL_BRANCH && -z $VCS_STATUS_TAG ]] &&  # <-- this line
  #    res+="${meta}@${clean}${VCS_STATUS_COMMIT[1,8]}"

  #  # Show tracking branch name if it differs from local branch.
  #  if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
  #    res+="${meta}:${clean}${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"
  #  fi

  #  # Display "wip" if the latest commit's summary contains "wip" or "WIP".
  #  if [[ $VCS_STATUS_COMMIT_SUMMARY == (|*[^[:alnum:]])(wip|WIP)(|[^[:alnum:]]*) ]]; then
  #    res+=" ${modified}wip"
  #  fi

  #  # ⇣42 if behind the remote.
  #  (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${clean}⇣${VCS_STATUS_COMMITS_BEHIND}"
  #  # ⇡42 if ahead of the remote; no leading space if also behind the remote: ⇣42⇡42.
  #  (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
  #  (( VCS_STATUS_COMMITS_AHEAD  )) && res+="${clean}⇡${VCS_STATUS_COMMITS_AHEAD}"
  #  # ⇠42 if behind the push remote.
  #  (( VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" ${clean}⇠${VCS_STATUS_PUSH_COMMITS_BEHIND}"
  #  (( VCS_STATUS_PUSH_COMMITS_AHEAD && !VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" "
  #  # ⇢42 if ahead of the push remote; no leading space if also behind: ⇠42⇢42.
  #  (( VCS_STATUS_PUSH_COMMITS_AHEAD  )) && res+="${clean}⇢${VCS_STATUS_PUSH_COMMITS_AHEAD}"
  #  # *42 if have stashes.
  #  (( VCS_STATUS_STASHES        )) && res+=" ${clean}*${VCS_STATUS_STASHES}"
  #  # 'merge' if the repo is in an unusual state.
  #  [[ -n $VCS_STATUS_ACTION     ]] && res+=" ${conflicted}${VCS_STATUS_ACTION}"
  #  # ~42 if have merge conflicts.
  #  (( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
  #  # +42 if have staged changes.
  #  (( VCS_STATUS_NUM_STAGED     )) && res+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
  #  # !42 if have unstaged changes.
  #  (( VCS_STATUS_NUM_UNSTAGED   )) && res+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
  #  # ?42 if have untracked files. It's really a question mark, your font isn't broken.
  #  # See POWERLEVEL9K_VCS_UNTRACKED_ICON above if you want to use a different icon.
  #  # Remove the next line if you don't want to see untracked files at all.
  #  (( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ${untracked}${(g::)POWERLEVEL9K_VCS_UNTRACKED_ICON}${VCS_STATUS_NUM_UNTRACKED}"
  #  # "─" if the number of unstaged files is unknown. This can happen due to
  #  # POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY (see below) being set to a non-negative number lower
  #  # than the number of files in the Git index, or due to bash.showDirtyState being set to false
  #  # in the repository config. The number of staged and untracked files may also be unknown
  #  # in this case.
  #  (( VCS_STATUS_HAS_UNSTAGED == -1 )) && res+=" ${modified}─"

  #  typeset -g my_git_format=$res
  #}
  #functions -M my_git_formatter 2>/dev/null

  ## Don't count the number of unstaged, untracked and conflicted files in Git repositories with
  ## more than this many files in the index. Negative value means infinity.
  ##
  ## If you are working in Git repositories with tens of millions of files and seeing performance
  ## sagging, try setting POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY to a number lower than the output
  ## of `git ls-files | wc -l`. Alternatively, add `bash.showDirtyState = false` to the repository's
  ## config: `git config bash.showDirtyState false`.
  #typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1

  ## Don't show Git status in prompt for repositories whose workdir matches this pattern.
  ## For example, if set to '~', the Git repository at $HOME/.git will be ignored.
  ## Multiple patterns can be combined with '|': '~(|/foo)|/bar/baz/*'.
  #typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'

  ## Disable the default Git status formatting.
  #typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  ## Install our own Git status formatter.
  #typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'
  #typeset -g POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_formatter(0)))+${my_git_format}}'
  ## Enable counters for staged, unstaged, etc.
  #typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1

  ## Icon color.
  #typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_COLOR=76
  #typeset -g POWERLEVEL9K_VCS_LOADING_VISUAL_IDENTIFIER_COLOR=244
  ## Custom icon.
  ## typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION='⭐'
  ## Custom prefix.
  ## typeset -g POWERLEVEL9K_VCS_PREFIX='%fon '

  ## Show status of repositories of these types. You can add svn and/or hg if you are
  ## using them. If you do, your prompt may become slow even when your current directory
  ## isn't in an svn or hg repository.
  #typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)

  ## These settings are used for repositories other than Git or when gitstatusd fails and
  ## Powerlevel10k has to fall back to using vcs_info.
  #typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=76
  #typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=76
  #typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=178

  ###########################[ status: exit code of the last command ]###########################
  ## Enable OK_PIPE, ERROR_PIPE and ERROR_SIGNAL status states to allow us to enable, disable and
  ## style them independently from the regular OK and ERROR state.
  #typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true

  ## Status on success. No content, just an icon. No need to show it if prompt_char is enabled as
  ## it will signify success by turning green.
  #typeset -g POWERLEVEL9K_STATUS_OK=false
  #typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=70
  #typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔'

  ## Status when some part of a pipe command fails but the overall exit status is zero. It may look
  ## like this: 1|0.
  #typeset -g POWERLEVEL9K_STATUS_OK_PIPE=true
  #typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=70
  #typeset -g POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION='✔'

  ## Status when it's just an error code (e.g., '1'). No need to show it if prompt_char is enabled as
  ## it will signify error by turning red.
  #typeset -g POWERLEVEL9K_STATUS_ERROR=false
  #typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=160
  #typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'

  ## Status when the last command was terminated by a signal.
  #typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
  #typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=160
  ## Use terse signal names: "INT" instead of "SIGINT(2)".
  #typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false
  #typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION='✘'

  ## Status when some part of a pipe command fails and the overall exit status is also non-zero.
  ## It may look like this: 1|0.
  #typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE=true
  #typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=160
  #typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION='✘'


  # Grey current time.
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=$grey
  # Format for the current time: 09:51:02. See `man 3 strftime`.
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
  # If set to true, time will update when you hit enter. This way prompts for the past
  # commands will contain the start times of their commands rather than the end times of
  # their preceding commands.
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false

  # Transient prompt works similarly to the builtin transient_rprompt option. It trims down prompt
  # when accepting a command line. Supported values:
  #
  #   - off:      Don't change prompt when accepting a command line.
  #   - always:   Trim down prompt when accepting a command line.
  #   - same-dir: Trim down prompt when accepting a command line unless this is the first command
  #               typed after changing current working directory.
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off

  # Instant prompt mode.
  #
  #   - off:     Disable instant prompt. Choose this if you've tried instant prompt and found
  #              it incompatible with your zsh configuration files.
  #   - quiet:   Enable instant prompt and don't print warnings when detecting console output
  #              during zsh initialization. Choose this if you've read and understood
  #              https://github.com/romkatv/powerlevel10k/blob/master/README.md#instant-prompt.
  #   - verbose: Enable instant prompt and print a warning when detecting console output during
  #              zsh initialization. Choose this if you've never tried instant prompt, haven't
  #              seen the warning, or if you are unsure what this all means.
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose

  # Hot reload allows you to change POWERLEVEL9K options after Powerlevel10k has been initialized.
  # For example, you can type POWERLEVEL9K_BACKGROUND=red and see your prompt turn red. Hot reload
  # can slow down prompt by 1-2 milliseconds, so it's better to keep it turned off unless you
  # really need it.
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  # NOTE Changed this
  # Custom prefix.



  # If p10k is already loaded, reload configuration.
  # This works even with POWERLEVEL9K_DISABLE_HOT_RELOAD=true.
  (( ! $+functions[p10k] )) || p10k reload
}

# Tell `p10k configure` which file it should overwrite.
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'


function prompt_om() {
  # 214 is saffron
  # 7 is grey
  p10k segment -b 2 -f 214 -t ' ॐ '
}

function prompt_face() {
 p10k segment -t '%(?,%F{green}[-_-]%f,%F{red}[ಠ_ಠ]%f)'
}
