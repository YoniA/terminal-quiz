#!/bin/zsh

echo "Question distribution in the database:\n"
sqlite3 quiz.db -header -column "select title as topic, count(did) as total from domains natural join items_domains group by did"

echo "\n"
echo "Total questions in the database:" $(sqlite3 quiz.db "select count(*) from items") 
