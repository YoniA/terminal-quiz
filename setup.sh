#!/bin/bash

echo "This will reset the database to an empty state, removing all questions and stats."
read -p "Type 'confirm' to continue; any other key to abort: " response

case $response in
	confirm)
		sqlite3 quiz.db "delete from stats"
		sqlite3 quiz.db "delete from items_domains"
		sqlite3 quiz.db "delete from domains"
		sqlite3 quiz.db "delete from keys"
		sqlite3 quiz.db "delete from items"
		echo "Done. Database is empty and ready to use."
		;;
	*)
		echo "Aborted."
		exit
		;;
esac
