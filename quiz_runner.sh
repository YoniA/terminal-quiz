#!/bin/zsh


SEPARATOR="\n\n"
RED='\e[31m'
GREEN='\e[32m'
BLINK='\e[5m'
MASTERED_THRESHOLD=5



show_random_item() {

	size=$(sqlite3 quiz.db "select count(*) from stats where mastered=0")
	if [[ "$size" == "0" ]]; then
		echo "no items to show. exiting."
		exit
	fi
	
	# show only items that are not mastered yet
	iid=$(sqlite3 quiz.db "select iid from stats where mastered=0 order by random() limit 1")
	stem=$(sqlite3 quiz.db "select stem from items where iid=${iid}")
	ans1=$(sqlite3 quiz.db "select ans1 from items where iid=${iid}")
	ans2=$(sqlite3 quiz.db "select ans2 from items where iid=${iid}")
	ans3=$(sqlite3 quiz.db "select ans3 from items where iid=${iid}")
	ans4=$(sqlite3 quiz.db "select ans4 from items where iid=${iid}")

	echo "\n"
	print_title $iid
	
	print_item $stem $ans1 $ans2 $ans3 $ans4
	echo $SEPARATOR
	
	check_response
	update_stats $iid $response	
	is_mastered $iid

	vared -p "show another question? enter y to continue; any other key to exit: " -c choice
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
	topic=$(sqlite3 quiz.db "select title from domains natural join items_domains where iid=$1")
	title="Topic: $topic"
	echo "$title"
	printf "%0.s-" {1..${#title}} 	
	echo "\n"
}

print_item() {
	echo "$1"
	echo $SEPARATOR
	echo "a.\t$2"
	echo "b.\t$3"
	echo "c.\t$4"
	echo "d.\t$5"	
}

print_feedback() {
	key=$(sqlite3 quiz.db "select key from keys where iid=$1")

	if [[ "$key" == "$2" ]]; then
		echo -e "your response $2 is ${GREEN}correct!"
	else
		echo -e "your response $2 is ${RED}wrong."
	fi
}

update_stats() {
	attempts=$(sqlite3 quiz.db "select attempts from stats where iid=$1")
	((attempts++))
	
	rights=$(sqlite3 quiz.db "select rights from stats where iid=$1")
	streak=$(sqlite3 quiz.db "select streak from stats where iid=$1")
	mastered=0;

	key=$(sqlite3 quiz.db "select key from keys where iid=$1")
	if [[ "$key" == "$2" ]]; then
		((rights++))
		((streak++))
		
		if [[ "$streak" == "$MASTERED_THRESHOLD" ]]; then
			((mastered++))
		fi
	else
		zero=0
		streak=$zero
		mastered=$zero
	fi
	
	sqlite3 quiz.db "update stats set attempts=${attempts}, rights=${rights}, streak=${streak}, mastered=$mastered where iid=$1"
	echo "stats: attempts: ${attempts}, rights: ${rights}, streak=${streak}, mastered=${mastered}"	
}


is_mastered() {
	mastered=$(sqlite3 quiz.db "select mastered from stats where iid=$1")
	if [[ "$mastered" == 1 ]]; then
		echo "${BLINK}CONGRATULATIONS! You have mastered this question! it will not show again."
	fi
}


check_response() {
	# zsh equivalent to 'read -p' in bash
	vared -p "answer (a/b/c/d): " -c response
	case $response in
		a|b|c|d) 
			print_feedback $iid $response
			;;
			
		*) 
			echo "invalid response. try again."
			check_response;
			;;
	esac
}


show_random_item


# colors: https://misc.flogisoft.com/bash/tip_colors_and_formatting