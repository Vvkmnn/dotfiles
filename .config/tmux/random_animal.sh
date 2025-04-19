#!/bin/sh

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
    "🐕"  # Dog
    "🐈"  # Cat
    "🐎"  # Horse
    "🦬"  # Bison
    "🐄"  # Cow
    "🐖"  # Pig
    "🐑"  # Sheep
    "🐐"  # Goat
    "🐪"  # Camel with one hump
    "🐫"  # Camel with two humps
    "🦙"  # Llama
    "🦒"  # Giraffe
    "🐘"  # Elephant
    "🦣"  # Mammoth
    "🦏"  # Rhinoceros
    "🦛"  # Hippopotamus
    "🐇"  # Rabbit
    "🦔"  # Hedgehog
    "🦇"  # Bat
    "🦘"  # Kangaroo
    "🦡"  # Badger
    "🦃"  # Turkey
    "🐓"  # Rooster
    "🦢"  # Swan
    "🦉"  # Owl
    "🦤"  # Dodo
    "🦚"  # Peacock
    "🦜"  # Parrot
    "🐊"  # Crocodile
    "🐢"  # Turtle
    "🦎"  # Lizard
    "🐍"  # Snake
    "🐉"  # Dragon
    "🦕"  # Sauropod
    "🦖"  # T-Rex
    "🐋"  # Whale
    "🐬"  # Dolphin
    "🦭"  # Seal
    "🐟"  # Fish
    "🐠"  # Tropical Fish
    "🐡"  # Blowfish
    "🦈"  # Shark
    "🐙"  # Octopus
    "🦀"  # Crab
    "🦞"  # Lobster
    "🦑"  # Squid
    "🐌"  # Snail
    "🦋"  # Butterfly
    "🐝"  # Bee
    "🪲"  # Beetle
    "🐞"  # Ladybug
    "🦗"  # Cricket
    "🦂"  # Scorpion
    "🐜"  # Ant
    "🕷️"  # Spider
    "🐩"  # Poodle
    "🦥"  # Sloth
    "🦦"  # Otter
    "🦨"  # Skunk
    "🦩"  # Flamingo
    "🦫"  # Beaver
    "🐧"  # Penguin
    "🦅"  # Eagle
    "🐦"  # Bird
    "🐥"  # Chick
    "🦆"  # Duck
    "🦢"  # Swan
    "🦉"  # Owl
    "🦩"  # Flamingo
    "🐕"  # Service Dog
    "🐈"  # Black Cat
    "🐿️"  # Squirrel
)

    # "🦄"  # Unicorn
    # "🦝"  # Raccoon
    # "🐸"  # Frog
    # "🐺"  # Wolf
    # "🦊"  # Fox
    # "🐗"  # Wild Boar

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
