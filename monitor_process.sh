#!/bin/bash

# Check if script is running and kill all instances
function kill_proc {
	while read -r pidline 
	do
		# Search through all procs with matching name, kill all except our own
		if [ "$$" != "$pidline" ]
		then
			kill -9 "$pidline" 2> /dev/null
		fi
	done < <(ps o pid= -C $(basename "$0"))
}


# Calculate percentage and trigger led, input one is proc name, two is memory/cpu, three rate
function calc_trigger {
	value=0
	while read -r procline
	do
		# Search through all procs with name matching
		if [ "$2" == "memory" ]
		then
			# If monitoring memory, extract memory column and add to value
			procval=$(echo $procline | awk '{ print $2 }')
			value=$(bc <<< "scale=1; $value + $procval")
		elif [ "$2" == "cpu" ]
		then
			# If cpu, extract cpu column
			procval=$(echo $procline | awk '{ print $3 }')
			value=$(bc <<< "scale=1; $value + $procval")
		fi
	done < <(ps o pid=,%mem=,%cpu= -C $1)
	# blink the led with value and rate
	blink_led $value $3 $4
}
#sudo sh -c "echo 1 > $2/brightness"

	
function blink_led {
	#set the rate of blinks per second
	value=$1
	rate=$2
	led=$3
	# calculate the blink on time factoring in value and rate
	blinkon=$(bc <<< "scale=5; $value/100/$rate")
	# calculate the blink off time
	blinkoff=$(bc <<< "scale=5; 1/$rate - $blinkon")
	# if either blinkon or blinkoff are 0, don't do a momemtary blinkon/blinkoff
	if [ "$blinkon" != '0' ]
	then
		#turn led on $led
		sudo sh -c "echo 1 > $led/brightness"
		#sleep for the blinkon time
		sleep $blinkon
	fi
	if [ "$blinkoff" != '0' ]
	then
		#turn led off
		sudo sh -c "echo 0 > $led/brightness"
		#sleep for the blink off time
		sleep $blinkoff
	fi	
}

kill_proc

mode="memory"
rate="1"
while getopts ":m:p:l:k" opt; do
	case ${opt} in
		m  ) if [[ "$OPTARG" == "memory" ]]; then
		 	mode="memory"
		     elif [[ "$OPTARG" == "cpu" ]]; then
		 	mode="cpu"
		     else
		 	echo "Invalid option: $OPTARG" 1>&2
		 	exit
		     fi
		   ;;
		p  ) process="$OPTARG"
		   ;;
		l  ) led="$OPTARG"
		   ;;
		k  ) exit # just exit out, process already killed
		   ;;
		\? ) echo "Invalid option: $OPTARG" 1>&2
		   ;;
		:  ) echo "Invalid option: $OPTARG requires an argument" 1>&2
		   ;;
		
	esac
done
shift $((OPTIND -1))

if [ "a" == "a$process" ]
then
	echo "-p [option] is required"
	exit
fi
if [ "a" == "a$mode" ]
then
	echo "-m [option] is required"
	exit
fi
if [ "a" == "a$led" ]
then
	echo "-l [option] is required"
	exit
fi

while :
do
	calc_trigger $process $mode $rate $led
done

#to be sure, we turn off led once finished
sudo sh -c "echo 0 > $led/brightness"
