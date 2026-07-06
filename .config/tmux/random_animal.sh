#!/bin/bash

set_random_emoji() {

	# Define the emojis list only if it's not already defined
	if [ -z "$EMOJIS_DEFINED" ]; then
		# EMOJIS=(
		#    "🐕" "🐈" "🐎" "🦬" "🐄" "🐖" "🐑" "🐐" "🐪"
		#    "🐫" "🦙" "🦒" "🐘" "🦣" "🦏" "🦛" "🐇" "🦔" "🦇"
		#    "🦘" "🦡" "🦃" "🐓" "🦢" "🦉" "🦤" "🦚" "🦜" "🐊"
		#    "🐢" "🦎" "🐍" "🐉" "🦕" "🦖" "🐋" "🐬" "🦭" "🐟"
		#    "🐠" "🐡" "🦈" "🐙" "🦀" "🦞" "🦑" "🐌" "🦋"
		#    "🐝" "🪲" "🐞" "🦗" "🦂" "🐜" "🕷️" "🐩"
		# )

		EMOJIS=(
			"🐕"   # Dog
			"🐈"   # Cat
			"🐈‍⬛" # Black Cat
			"🐎"   # Horse
			"🦬"   # Bison
			"🐄"   # Cow
			"🐖"   # Pig
			"🐑"   # Sheep
			"🐐"   # Goat
			"🐫"   # Camel with two humps
			"🦙"   # Llama
			"🦒"   # Giraffe
			"🐘"   # Elephant
			"🦣"   # Mammoth
			"🦏"   # Rhinoceros
			"🦛"   # Hippopotamus
			"🐇"   # Rabbit
			"🦔"   # Hedgehog
			"🦇"   # Bat
			"🦘"   # Kangaroo
			"🦡"   # Badger
			"🦃"   # Turkey
			"🐓"   # Rooster
			"🦢"   # Swan
			"🦉"   # Owl
			"🦤"   # Dodo
			"🦚"   # Peacock
			"🦜"   # Parrot
			"🐊"   # Crocodile
			"🐢"   # Turtle
			"🦎"   # Lizard
			"🐍"   # Snake
			"🐉"   # Dragon
			"🦕"   # Sauropod
			"🦖"   # T-Rex
			"🐋"   # Whale
			"🫍"   # Orca (Unicode 17.0 — needs macOS/iOS 26.4+ to render)
			"🐬"   # Dolphin
			"🦭"   # Seal
			"🦈"   # Shark
			"🐙"   # Octopus
			"🦀"   # Crab
			"🦞"   # Lobster
			"🦑"   # Squid
			"🐌"   # Snail
			"🐝"   # Bee
			"🦗"   # Cricket
			"🦂"   # Scorpion
			"🐜"   # Ant
			"🕷️"  # Spider
			"🦥"   # Sloth
			"🦦"   # Otter
			"🦩"   # Flamingo
			"🦫"   # Beaver
			"🦅"   # Eagle
			"🦆"   # Duck
			"🦓"   # Zebra
			"🦌"   # Deer
			"🐂"   # Ox
			"🐃"   # Water Buffalo
			"🐏"   # Ram
			"🐁"   # Mouse
			"🐀"   # Rat
			"🐅"   # Tiger
			"🐆"   # Leopard
			"🐦‍⬛" # Black Bird
			"🐦‍🔥" # Phoenix
			"🕊️"  # Dove
			"🪿"   # Goose
			"🪼"   # Jellyfish
			"🦐"   # Shrimp
			"🐿️"  # Squirrel
			"🐛"   # Caterpillar
		)

		# "🪳"  # Cockroach
		# "🐪"  # Camel with one hump
		# "🐟"  # Fish
		# "🐠"  # Tropical Fish
		# "🐡"  # Blowfish
		# "🐧"  # Penguin
		# "🐦"  # Bird
		# "🐩"  # Poodle
		# "🐥"  # Chick
		# "🦄"  # Unicorn
		# "🦝"  # Raccoon
		# "🐸"  # Frog
		# "🐺"  # Wolf
		# "🦊"  # Fox
		# "🐗"  # Wild Boar
		# "🦨"  # Skunk
		# "🦋"  # Butterfly
		# "🪲"  # Beetle
		# "🐞"  # Ladybug

		export EMOJIS_DEFINED=yes
	fi

	#

	# Use RANDOM and modulo to select a random emoji
	RANDOM_EMOJI=${EMOJIS[$RANDOM % ${#EMOJIS[@]}]}

	# Set the random emoji in tmux environment
	tmux set-environment -g @random_animal "$RANDOM_EMOJI"
}

# Only call set_random_emoji when needed to reduce overhead
# This acts as a simple form of 'lazy loading', executing the function only when the script is actually used
set_random_emoji

# #!/bin/sh
# EMOJIS=(
#    🐕 🐩 🐈 🐎 🦬 🐄 🐖 🐑 🐐 🐪 🐫 🦙 🦒 🐘 🦣 🦏 🦛 🐇 🦔 🦇 🦘 🦡 🦃 🐓 🦢 🦉 🦤  🦚 🦜 🐊 🐢 🦎 🐍 🐉 🦕 🦖 🐋 🐬 🦭 🐟 🐠 🐡 🦈 🐙 🦀 🦞 🦑 🐌 🦋 🐜 🐝 🪲 🐞 🦗  🕷️ 🦂
# )
#
# # "🦚" "🦐" "🦦" "🦥" "🦌" "🦒"
#
# RANDOM_EMOJI=${EMOJIS[$RANDOM % ${#EMOJIS[@]}]}
#
# tmux set-environment -g @random_animal "$RANDOM_EMOJI"
