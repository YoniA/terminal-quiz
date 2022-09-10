#!/bin/bash


readonly SEPARATOR="\n\n"
readonly BOLD='\e[1m'
readonly RED='\e[31m'
readonly GREEN='\e[32m'
readonly YELLOW='\e[93m'
readonly BLUE_BG='\e[44m'
readonly YELLOW_BG='\e[103m'
readonly MAGENTA_BG='\e[45m'
readonly BLINK='\e[5m'
readonly RESET='\e[0m'
readonly MASTERED_THRESHOLD=5
db="quiz.db"
title="title"

while getopts "d:t:h" opt
	do
        case $opt in
        d)
					db=$OPTARG 
					;;

        t)
					title=$OPTARG
					;;

				h)
					echo -e "USAGE:"
					echo -e "./quiz_runner.sh [-d database] [-t topic]"
					exit
					;;
        esac
done



show_random_item() {
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

	echo -e "\n"
	print_title $iid
	
	print_item "$stem" "$ans1" "$ans2" "$ans3" "$ans4"
	echo -e $SEPARATOR
	
	check_response

	echo -e
	read -p "Show another question? Enter y to continue; any other key to exit: " choice
	case $choice in
		y) 
			show_random_item
			;;
		*) 
			exit
			;;
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
	key=$(sqlite3 $db "select key from keys where iid=$1")

	if [[ "$key" == "$2" ]]; then
		echo -e -e "Your response $2 is ${GREEN}correct!${RESET}"
	else
		echo -e -e "Your response $2 is ${RED}wrong.${RESET}"
	fi
}

update_stats() {
	attempts=$(sqlite3 $db "select attempts from stats where iid=$1")
	((attempts++))
	
	rights=$(sqlite3 $db "select rights from stats where iid=$1")
	streak=$(sqlite3 $db "select streak from stats where iid=$1")
	mastered=0;

	key=$(sqlite3 $db "select key from keys where iid=$1")
	if [[ "$key" == "$2" ]]; then
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
	echo -e "${BOLD}STATS:${RESET} Attempts: ${attempts}, Rights: ${rights}, Streak: ${streak}, Mastered: ${mastered}"
}


check_response() { 
	read -p "Answer (a/b/c/d or s to skip): " response
	case $response in
		a|b|c|d) 
			print_feedback $iid $response
			update_stats $iid $response 
			;;
			
		s) 
			show_random_item
			;;
		*) 
			echo -e "Invalid response. Try again."
			check_response;
			;;
	esac
}

show_random_item


# colors: https://misc.flogisoft.com/bash/tip_colors_and_formatting
