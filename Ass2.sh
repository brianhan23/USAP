#!/bin/bash

function main_menu {
	echo "Welcome to Led_Konfigurator!"
	echo "============================"
	echo "Please select an led to configure:"
	i=0
	for led in /sys/class/leds/*; do
		let "i++"
		echo "$i. $(basename "$led")"
	done
	let "i++"
	echo "$i. Quit"
	read -p "Please enter a number (1-$i) for the led to configure or quit: " input
	j=0
	for led in /sys/class/leds/*; do
                let "j++"
		if (i==j); then
			led_menu "$(basename "$led")"	
		fi	
        done
}

function led_menu {
	echo $1
	echo "=========="
	echo "What would you like to do with this led?"
	echo "1) turn on"
	echo "2) turn off"
	echo "3) associate with a system event"
	echo "4) associate with the performance of a process"
	echo "5) stop association with a process' performance"
	echo "6) quit to main menu"
	read -p "Please enter a number (1-6) for your choice:" input
	case "$input" in
		1) sudo sh -c "echo 1 > /sys/class/leds/$1/brightness";;
		2) sudo sh -c "echo 0 > /sys/class/leds/$1/brightness";;
		*) echo "Please enter a number (1-6) for your choice:" ;;
	esac 
}

function turn_led_on {
	sudo sh -c "echo 1 > /sys/class/leds/$1/brightness"
}

function turn_led_off {
	sudo sh -c "echo 0 > /sys/class/leds/$1/brightness"
}

main_menu
#led_menu "led0"
#turn_led_off "led0"
