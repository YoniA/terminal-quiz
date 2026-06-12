#!/bin/bash

count=${1:-1}

# empty file if it exists
if [ -e questions.txt ]; then
	sed -i '1,$d' questions.txt
fi

echo -e "\n---\n\n---\n\n---\n\n---\n\n---\n\n---\n" > questions.txt
for (( i=2; i<=$count; i++ )) 
do
	echo -e "###\n\n---\n\n---\n\n---\n\n---\n\n---\n\n---\n" >> questions.txt
done
