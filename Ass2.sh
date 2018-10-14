#!/bin/bash

# Function declaration for the main menu
function main_menu {
	# Menu is inside of a loop, will refresh menu unless user quits
	while :
	do
		clear
		echo "Welcome to Led_Konfigurator!"
		echo "============================"
		echo "Please select an led to configure:"
		# Loop through all leds in the leds directory, store the path
		# to each led in an array with index equal to option menu number
		i=0
		for led in /sys/class/leds/*; do
			let "i++"
			# We strip the full path for dislay only
			echo "$i. $(basename "$led")"
			opt["$i"]=$led
		done
		let "i++"
		echo "$i. Quit"
		# Prompt user for input
		read -p "Please enter a number (1-$i) for the led to configure or quit: " input
		# Handle quit case first, we know the value.
		# If the input is not in the range of inputs, report error
		case "$input" in
			$i) exit;;
			[1-$i]) led_menu ${opt[$input]};;
			*) echo "ERROR: invalid input";;
		esac
	done
}

# Function declaration for the led menu
function led_menu {
	# Menu is inside of a loop, will refresh after user input
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
			4) process_performance_menu $1;;
			5) stop_process_performance $1;;
			6) break;;
			*) echo "ERROR: Invalid input";;
		esac 
	done
}

# Function declaration for the system event menu
function sys_event_menu {
	while :
	do
		clear
		echo "Associate Led with a system Event"
		echo "================================="
		echo "Available events are:"
		echo "---------------------"
		# Read the leds trigger file and loop through line by line
		read -r line < $1/trigger
		page=""
		i=0
                for trigger in $line; do
                        let "i++"
			# Check for square brackets
			if [[ ${trigger:0:1} == '[' ]]
			then
				# Strip square brackets
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
			$i) break;;
			*) trigger_event $1 ${opt[$input]};;
			*) echo "ERROR: Invalid input";;
		esac	
	done
}

function process_performance_menu {
	while :
	do
		clear
		echo "Associate LED with the performance of a process"
		echo "-----------------------------------------------"
		read -p "Please enter the name of the program to monitor(partial names are ok): " input
		procname=$(ps | grep -i $input | awk '{ print $4 }' | sort | uniq)

		if [ -z "$procname" ]
		then
			echo "ERROR: No match found"
		elif [ "$(echo "$procname" | wc -l)" -gt 1 ]
		then
			echo "Name Conflict"
			echo "-------------"
			echo "I have detected a name conflict. Do you want to monitor:"
			i=0
			while read -r line
			do
				let "i++"
				echo "$i) $line"
				opt["$i"]=$line
			done < <(echo "$procname")
			let "i++"
			echo "$i) Cancel Request"
			read -p "Please select an option (1-$i): " input
		case "$input" in
				$i) break;;
				*) procname=${opt[$input]};;
			esac
		fi	
		echo "$procname"
		read -p "Do you wish to 1) monitor memory or 2) monitor cpu? [enter memory or cpu]: " input
		if [ "$input" == "memory" ]
		then
			monitor_memory $procname
			break
		elif [ "$input" == "cpu" ]
		then
			monitor_cpu $procname
			break
		else
			echo "ERROR: Invalid input"
		fi
	done
} 

# Functions to do actions
function turn_led_on {
	sudo sh -c "echo 1 > $1/brightness"
}

function turn_led_off {
	sudo sh -c "echo 0 > $1/brightness"
}

function trigger_event {
	sudo sh -c "echo $2 > $1/trigger"
}

function monitor_memory {
	:
	# monitor memory script
}

function monitor_cpu {
	:
	# monitor cpu script
}

function stop_process_performance {
	:
	# incomplete
}

# Disable control-c interrupt
trap '' 2
# Execute Main Menu
main_menu
# Enable control-c interrup
trap 2
#led_menu "led0"
#turn_led_off "led0"
