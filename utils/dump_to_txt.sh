#!/bin/zsh

sqlite3 quiz.db -line .output  "select * from items" > dump.txt
