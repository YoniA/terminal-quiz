#!/bin/bash

db=${1:-quiz.db}

sqlite3 $db -line .output  "select iid, title, stem, ans1, ans2, ans3, ans4, key from items natural join keys natural join items_domains natural join domains" > dump_$(date +'%F_%T').txt
