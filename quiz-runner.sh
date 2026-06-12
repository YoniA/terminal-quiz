#!/bin/bash

# constants
readonly SEPARATOR="\n\n"
readonly MASTERED_THRESHOLD=5
readonly MAX_CONTENT_WIDTH=78

# terminal ANSI colors
readonly RED="$(tput setaf 1)"
readonly GREEN="$(tput setaf 2)"
readonly YELLOW="$(tput setaf 3)"
readonly BLUE="$(tput setaf 4)"
readonly CYAN="$(tput setaf 6)"
readonly BOLD="$(tput bold)"
readonly BLINK="$(tput blink)"
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
		compute_layout
		size=$(sqlite3 $db "select count(*) from stats natural join items_domains natural join domains where title=\"${title}\" and mastered=0")
		if [[ "$size" == "0" ]]; then
			echo -e "${PAD}no items to show. exiting."
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

		print_title $iid
		print_item "$stem" "$ans1" "$ans2" "$ans3" "$ans4"

		check_response

		print_divider
		read -p "${PAD}Press Enter for next question, or any other key to exit: " choice
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

# compute a centered content area: CONTENT_WIDTH columns wide, capped at
# MAX_CONTENT_WIDTH, with PAD spaces of margin on each side
compute_layout() {
	local term_width=$(tput cols)
	CONTENT_WIDTH=$term_width
	if (( CONTENT_WIDTH > MAX_CONTENT_WIDTH )); then
		CONTENT_WIDTH=$MAX_CONTENT_WIDTH
	fi
	PAD=$(printf '%*s' $(( (term_width - CONTENT_WIDTH) / 2 )) '')
}

# print $3, word-wrapped to CONTENT_WIDTH, indented by PAD.
# $1 is printed before the first line, $2 is its visible width (used to
# align continuation lines under it; may contain color codes)
print_wrapped() {
	local prefix="$1" prefix_width="$2" text="$3"
	local indent=$(printf '%*s' "$prefix_width" '')
	local wrap_width=$((CONTENT_WIDTH - prefix_width))
	(( wrap_width < 10 )) && wrap_width=10

	local first=true
	while IFS= read -r line; do
		if $first; then
			echo -e "${PAD}${prefix}${line}"
			first=false
		else
			echo -e "${PAD}${indent}${line}"
		fi
	done < <(echo -e "$text" | fold -s -w "$wrap_width")
}

print_divider() {
	printf "%s${BLUE}" "$PAD"
	printf '─%.0s' $(seq 1 "$CONTENT_WIDTH")
	printf "${RESET}\n"
}

print_title() {
	local topic=$(sqlite3 $db "select title from domains natural join items_domains where iid=$1")
	local remaining=$(sqlite3 $db "select count(*) from stats natural join items_domains natural join domains where title=\"${title}\" and mastered=0")
	print_divider
	echo -e "${PAD}  ${BOLD}${BLUE}Topic:${RESET} ${topic}   ${BLUE}Remaining:${RESET} ${remaining}"
	print_divider
	echo
}

print_item() {
	printf "${BOLD}"
	print_wrapped "" 0 "$1"
	printf "${RESET}\n"

	print_wrapped "  ${CYAN}a)${RESET}  " 6 "$2"
	print_wrapped "  ${CYAN}b)${RESET}  " 6 "$3"
	print_wrapped "  ${CYAN}c)${RESET}  " 6 "$4"
	print_wrapped "  ${CYAN}d)${RESET}  " 6 "$5"
	echo
}

get_answer() {
	case $1 in
		a) echo "$ans1" ;;
		b) echo "$ans2" ;;
		c) echo "$ans3" ;;
		d) echo "$ans4" ;;
	esac
}
print_feedback() {
	echo
	if [[ "$shuffled_key" == "$2" ]]; then
		echo -e "${PAD}  ${GREEN}${BOLD}✓  Correct!${RESET}"
	else
		echo -e "${PAD}  ${RED}${BOLD}✗  Wrong.${RESET}"
		print_wrapped "  Correct answer: ${BOLD}${shuffled_key})${RESET}  " 22 "$(get_answer $shuffled_key)"
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
			echo
			echo -e "${PAD}  ${BLINK}${BOLD}${YELLOW}★  Mastered!${RESET} This question won't appear again."
		fi
	else
		zero=0
		streak=$zero
		mastered=$zero
	fi
	
	sqlite3 $db "update stats set attempts=${attempts}, rights=${rights}, streak=${streak}, mastered=$mastered where iid=$1"

	local bar=""
	for ((i=0; i<streak; i++)); do bar+="█"; done
	for ((i=streak; i<MASTERED_THRESHOLD; i++)); do bar+="░"; done

	echo
	echo -e "${PAD}  ${BOLD}Attempts:${RESET} ${attempts}   ${BOLD}Correct:${RESET} ${rights}   ${BOLD}Streak:${RESET} ${GREEN}${bar}${RESET} ${streak}/${MASTERED_THRESHOLD}"
	echo
}


delete_question() {
	read -p "${PAD}Delete this question permanently? Type 'confirm' to delete, anything else to cancel: " confirmation
	if [[ "$confirmation" == "confirm" ]]; then
		sqlite3 $db "delete from keys where iid=$iid"
		sqlite3 $db "delete from items_domains where iid=$iid"
		sqlite3 $db "delete from stats where iid=$iid"
		sqlite3 $db "delete from items where iid=$iid"
		echo
		echo -e "${PAD}  ${RED}Question deleted.${RESET}"
		return 0
	else
		echo
		echo -e "${PAD}  Deletion cancelled."
		return 1
	fi
}

check_response() {
	while true; do
		read -p "${PAD}Answer (a/b/c/d, s to skip, x to delete): " response
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

			x)
				if delete_question; then
					show_random_item
					return
				fi
				;;
			*)
				echo -e "${PAD}Invalid response. Try again."
				;;
		esac
	done
}

show_random_item


# colors: 
# https://misc.flogisoft.com/bash/tip_colors_and_formatting
# https://wiki.bash-hackers.org/scripting/terminalcodes
