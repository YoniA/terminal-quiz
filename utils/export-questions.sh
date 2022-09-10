#!/bin/bash

db=${1:-quiz.db}

sqlite3 -separator "---" $db "select title, stem, ans1, ans2, ans3, ans4, key from domains natural join items_domains natural join items natural join keys" > questions.out.txt
