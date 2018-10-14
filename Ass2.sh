#!/bin/bash

function main_menu {
	while :
	do
		clear
		echo "Welcome to Led_Konfigurator!"
		echo "============================"
		echo "Please select an led to configure:"
		i=0
		for led in /sys/class/leds/*; do
			let "i++"
			echo "$i. $(basename "$led")"
			opt["$i"]=$led
		done
		let "i++"
		echo "$i. Quit"
		read -p "Please enter a number (1-$i) for the led to configure or quit: " input
		case "$input" in
			$i) exit;;
			*) led_menu ${opt[$input]};;
		esac
	done
}

function led_menu {
	while :
	do
		clear
		echo "$(basename "$1")"
		echo "=========="
		echo "What would you like to do with this led?"
		echo "1) turn on"
		echo "2) turn off"
		echo "3) associate with a system event"
		echo "4) associate with the performance of a process"
		echo "5) stop association with a process' performance"
		echo "6) quit to main menu"
		read -p "Please enter a number (1-6) for your choice: " input
		case "$input" in
			1) turn_led_on $1;;
			2) turn_led_off $1;;
			3) sys_event_menu $1;;
			6) break
		esac 
	done
}

function sys_event_menu {
	while :
	do
		clear
		echo "Associate Led with a system Event"
		echo "================================="
		echo "Available events are:"
		echo "---------------------"
		read -r line < $1/trigger
		page=""
		i=0
                for trigger in $line; do
                        let "i++"
			if [[ ${trigger:0:1} == '[' ]]
			then
				trigger=${trigger#*[}
				trigger=${trigger%]*}
				page="$page$i) $trigger*"$'\n'
			else
                        	page="$page$i) $trigger"$'\n'
			fi
			opt["$i"]=$trigger
                done
		let "i++"
                page="$page$i) Quit to previous menu"
		echo "$page" | more

		read -p "Please select an option (1-$i): " input
		case "$input" in
			$i) break
		esac	
	done
}

function turn_led_on {
	sudo sh -c "echo 1 > $1/brightness"
}

function turn_led_off {
	sudo sh -c "echo 0 > $1/brightness"
}


main_menu
#led_menu "led0"
#turn_led_off "led0"
