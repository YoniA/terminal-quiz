#!/bin/bash 

db=${1:-quiz.db}

echo "CAUTION: This will WIPE OFF ALL CONTENT in the database, and CANNOT BE UNDONE. Do you wish to continue?"
read -p "Type 'confirm' to continue; any other key to abort: " response

case $response in
	confirm)
                sqlite3 $db "delete from stats"
		sqlite3 $db "delete from items_domains"
                sqlite3 $db "delete from domains"
		sqlite3 $db "delete from keys"
		sqlite3 $db "delete from items"

                echo -e "All tables are empty now."
		;;
	*)
		exit
		;;
esac
		

