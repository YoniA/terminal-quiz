#!/bin/zsh

echo "Question distribution in the database:\n"
sqlite3 quiz.db -header -column "select title as topic, count(did) as total from domains natural join items_domains group by did"
