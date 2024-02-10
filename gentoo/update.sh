#!/bin/bash

function user_prompt {
    local command="$1"
    echo "Next: $command"
    read -p "Do you want to proceed? (y/n/q): " choice
    case $choice in
        y|Y) return 0;;
        n|N) return 1;;
        q|Q) echo "Ok, quitting"; exit;;
        *) echo "Invalid choice."; user_prompt;;
    esac
}

commands=(
	"emerge --update --deep --changed-use --newuse --with-bdeps=y @world --ask"
	"emerge @preserved-rebuild"
	"emerge @module-rebuild"
	"emerge --depclean --ask"
	"grub-mkconfig -o /boot/grub/grub.cfg"
)

command="eix-sync"
user_prompt "$command"
if [ $? -eq 0 ]; then
    eval "$command"
fi

emerge --update --deep --changed-use --newuse --with-bdeps=y @world --ask --pretend | genlop --pretend 

for command in "${commands[@]}"; do
    user_prompt "$command"
    if [ $? -eq 0 ]; then
        eval "$command"
    else
        echo "Skipping"
    fi
done

echo "Done - Have fun with Gentoo"
