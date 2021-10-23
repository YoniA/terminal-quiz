#!/bin/bash

count=${1:-1}

touch questions.txt

echo -e "\n---\n\n---\n\n---\n\n---\n\n---\n\n---\n" >> questions.txt
for (( i=2; i<=$count; i++ )) 
do
	echo -e "###\n\n---\n\n---\n\n---\n\n---\n\n---\n\n---\n" >> questions.txt
done
