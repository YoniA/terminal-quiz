#!/bin/zsh


SEPARATOR="\n\n"
stem=$(sqlite3 quiz.db "select stem from items where item_id=1")
ans1=$(sqlite3 quiz.db "select ans1 from items where item_id=1")
ans2=$(sqlite3 quiz.db "select ans2 from items where item_id=1")
ans3=$(sqlite3 quiz.db "select ans3 from items where item_id=1")
ans4=$(sqlite3 quiz.db "select ans4 from items where item_id=1")



print_item(){
echo "$1"
echo "\n\n"
echo "a.\t $2"
echo "b.\t $3"
echo "c.\t $4"
echo "d.\t $5"	
}

check_correctness() {
	# todo
}


print_item $stem $ans1 $ans2 $ans3 $ans4
echo $SEPARATOR

# zsh equivalent to 'read -p' in bash
vared -p 'answer: ' -c response
echo your response is: $response
