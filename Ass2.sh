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
			4) process_performance_menu $1;;
			6) break;;
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
			$i) break;;
			*) trigger_event $1 ${opt[$input]};;
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
	//monitor memory script
}

function monitor_cpu {
	//#monitor cpu script
}

trap '' 2
main_menu
trap 2
#led_menu "led0"
#turn_led_off "led0"
