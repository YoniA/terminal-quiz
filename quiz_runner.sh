#!/bin/bash

# constants
readonly SEPARATOR="\n\n"
readonly MASTERED_THRESHOLD=5

# terminal ANSI colors
readonly RED="$(tput setaf 1)" 
readonly GREEN="$(tput setaf 2)" 
readonly BLUE="$(tput setaf 4)" 
readonly BOLD="$(tput bold)" 
readonly BLINK="$(tput bold)" 
readonly RESET="$(tput sgr0)" 

# default values
db="quiz.db"
title="title"

while getopts "d:t:h" opt
	do
        case $opt in
        d)
					db=$OPTARG 
					;;

        t)
					title=$OPTARG ;;

				h)
					echo -e "USAGE:"
					echo -e "./quiz_runner.sh [-d database] [-t topic]"
					exit
					;;
        esac
done



show_random_item() {
	while true; do
		clear
		size=$(sqlite3 $db "select count(*) from stats natural join items_domains natural join domains where title=\"${title}\" and mastered=0")
		if [[ "$size" == "0" ]]; then
			echo -e "no items to show. exiting."
			exit
		fi

		# show only items that are not mastered yet
		iid=$(sqlite3 $db "select iid from stats natural join items_domains natural join domains where title=\"${title}\" and mastered=0 order by streak, random() limit 1")

		stem=$(sqlite3 $db "select stem from items where iid=${iid}")
		ans1=$(sqlite3 $db "select ans1 from items where iid=${iid}")
		ans2=$(sqlite3 $db "select ans2 from items where iid=${iid}")
		ans3=$(sqlite3 $db "select ans3 from items where iid=${iid}")
		ans4=$(sqlite3 $db "select ans4 from items where iid=${iid}")

		shuffle_answers

		echo -e "\n"
		print_title $iid

		print_item "$stem" "$ans1" "$ans2" "$ans3" "$ans4"
		echo -e $SEPARATOR

		check_response

		echo -e
		read -p "Show another question? Press Enter or y to continue; any other key to exit: " choice
		case $choice in
			"" | y)
				;;
			*)
				exit
				;;
		esac
	done
}



shuffle_answers() {
	local db_key=$(sqlite3 $db "select key from keys where iid=$iid")
	local correct_idx
	case $db_key in
		a) correct_idx=0 ;;
		b) correct_idx=1 ;;
		c) correct_idx=2 ;;
		d) correct_idx=3 ;;
	esac

	local answers=("$ans1" "$ans2" "$ans3" "$ans4")
	for ((i=3; i>0; i--)); do
		local j=$((RANDOM % (i+1)))
		local tmp="${answers[$i]}"
		answers[$i]="${answers[$j]}"
		answers[$j]="$tmp"
		if [[ $correct_idx -eq $i ]]; then
			correct_idx=$j
		elif [[ $correct_idx -eq $j ]]; then
			correct_idx=$i
		fi
	done

	ans1="${answers[0]}"
	ans2="${answers[1]}"
	ans3="${answers[2]}"
	ans4="${answers[3]}"

	case $correct_idx in
		0) shuffled_key=a ;;
		1) shuffled_key=b ;;
		2) shuffled_key=c ;;
		3) shuffled_key=d ;;
	esac
}

print_title() {
	topic=$(sqlite3 $db "select title from domains natural join items_domains where iid=$1")
	title_line="Topic: $topic"
	echo -e $title_line
	printf "%0.s-" $(seq ${#title_line}) 
	echo -e "\n"
}

print_item() {
	echo -e "$1"
	echo -e $SEPARATOR
	echo -e "a.\t$2"
	echo -e "b.\t$3"
	echo -e "c.\t$4"
	echo -e "d.\t$5"
}
print_feedback() {
	if [[ "$shuffled_key" == "$2" ]]; then
		echo -e "Your response $2 is ${GREEN}correct!${RESET}"
	else
		echo -e "Your response $2 is ${RED}wrong.${RESET}"
	fi
}

update_stats() {
	attempts=$(sqlite3 $db "select attempts from stats where iid=$1")
	((attempts++))
	
	rights=$(sqlite3 $db "select rights from stats where iid=$1")
	streak=$(sqlite3 $db "select streak from stats where iid=$1")
	mastered=0;

	if [[ "$shuffled_key" == "$2" ]]; then
		((rights++))
		((streak++))
		
		if [[ "$streak" == "$MASTERED_THRESHOLD" ]]; then
			((mastered++))
			echo -e "${BLINK}${GREEN}CONGRATULATIONS!${RESET} You have mastered this question! it will not show again."

		fi
	else
		zero=0
		streak=$zero
		mastered=$zero
	fi
	
	sqlite3 $db "update stats set attempts=${attempts}, rights=${rights}, streak=${streak}, mastered=$mastered where iid=$1"
	echo -e
	echo -e "${BOLD}STATS:${RESET} ${BLUE}Attempts:${RESET} ${attempts}, ${BLUE}Rights:${RESET} ${rights}, ${BLUE}Streak:${RESET} ${streak}, ${BLUE}Mastered:${RESET} ${mastered}${RESET}"
}


check_response() {
	while true; do
		read -p "Answer (a/b/c/d or s to skip): " response
		case $response in
			a|b|c|d)
				print_feedback $iid $response
				update_stats $iid $response
				return
				;;

			s)
				show_random_item
				return
				;;
			*)
				echo -e "Invalid response. Try again."
				;;
		esac
	done
}

show_random_item


# colors: 
# https://misc.flogisoft.com/bash/tip_colors_and_formatting
# https://wiki.bash-hackers.org/scripting/terminalcodes
