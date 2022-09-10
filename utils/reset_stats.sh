#!/bin/bash

db=${1:-quiz.db}

sqlite3 $db "update stats set attempts=0, rights=0, streak=0, mastered=0"
