#!/bin/bash

db=${1:-quiz.db}

# prepare questions format
awk -F "###" '{print $0}' questions.txt | sed -z 's/\n/*/g' | sed 's/\*###\*/\n/g' | sed 's/\*---\*/---/g' | sed 's/"/""/g' | sed 's/*$/\n/' > records.tmp
iid=$(sqlite3 $db "select max(iid) from items")

while read line; do
	((++iid))
	echo $line | sed "s/^/$iid---/" > record.tmp && \
	iid=$(awk -F '---' '{print $1}' record.tmp)
	did=$(awk -F '---' '{print $2}' record.tmp)
	key=$(awk -F '---' '{print $8}' record.tmp)
	stem=$(awk -F '---' '{print $3}' record.tmp)
	# support multiple lines in stem
	stem=$(echo $stem | sed 's/*/\\n/g')

	ans1=$(awk -F '---' '{print $4}' record.tmp)
	ans2=$(awk -F '---' '{print $5}' record.tmp)
	ans3=$(awk -F '---' '{print $6}' record.tmp)
	ans4=$(awk -F '---' '{print $7}' record.tmp)

	sqlite3 $db "insert into items values (\"$iid\",\"$stem\",\"$ans1\",\"$ans2\",\"$ans3\",\"$ans4\")" && \
	sqlite3 $db "insert into keys values (\"$iid\",\"$key\")" && \
	sqlite3 $db "insert into items_domains values(\"$iid\",\"$did\")" && \
	sqlite3 $db "insert into stats values (\"$iid\",0,0,0,0)"
done < records.tmp

# delete temp files
rm record.tmp
rm records.tmp
