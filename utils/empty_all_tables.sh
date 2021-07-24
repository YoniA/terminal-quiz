#!/bin/zsh 

echo "CAUTION: This will WIPE OFF ALL CONTENT in the database, and CANNOT BE UNDONE. Do you wish to continue?"
vared -p "Type 'confirm' to continue; any other key to abort: " -c response

case $response in
	confirm)
                sqlite3 quiz.db "delete from stats"
		sqlite3 quiz.db "delete from items_domains"
                sqlite3 quiz.db "delete from domains"
		sqlite3 quiz.db "delete from keys"
		sqlite3 quiz.db "delete from items"

                echo "All tables are empty now."
		;;
	*)
		exit
		;;
esac
		

