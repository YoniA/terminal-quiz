#!/bin/bash

db=${1:-quiz.db}

echo -e "Question distribution in the database:\n"
sqlite3 $db -header -column "select did, title as topic, count(did) as total from domains natural join items_domains group by did"

echo -e "\n"
echo -e "Total questions in the database:" $(sqlite3 $db "select count(*) from items") 
