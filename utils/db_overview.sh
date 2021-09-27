#!/bin/zsh

db=${1:-quiz.db}

echo "Question distribution in the database:\n"
sqlite3 $db -header -column "select title as topic, count(did) as total from domains natural join items_domains group by did"

echo "\n"
echo "Total questions in the database:" $(sqlite3 $db "select count(*) from items") 
