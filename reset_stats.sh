#!/bin/zsh

sqlite3 quiz.db "update stats set attempts=0, rights=0, streak=0, mastered=0"
