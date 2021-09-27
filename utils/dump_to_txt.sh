#!/bin/zsh

db=${1:-quiz.db}

sqlite3 $db -line .output  "select * from items" > dump_$(date +'%F_%T').txt
