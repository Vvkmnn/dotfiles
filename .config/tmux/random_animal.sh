#!/bin/bash
EMOJIS=(
	"🦋" "🐢" "🦑" "🦐" "🦞" "🦀"
	"🐙" "🦈" "🐬" "🐊" "🐅" "🦌"
	"🦏" "🐘" "🦣" "🦙" "🐑" "🐐"
	"🐕" "🐈" "🦚" "🦜" "🦢" "🦔"
	"🐇" "🦦" "🦥" "🦥" "🦥" "🦥"
)

RANDOM_EMOJI=${EMOJIS[$RANDOM % ${#EMOJIS[@]}]}

tmux set-environment -g @random_animal "$RANDOM_EMOJI"
