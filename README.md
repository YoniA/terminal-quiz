# About

A simple bash script that displays random questions in terminal.
The default database contains questions about Web development topics - HTML, CSS, JavaScript, Rails, Angular, Linux etc. But it can also be used for foreign language learning, or anything 
you want to memorize.

Upon invocation, the script queries a custom `sqlite` database for a random question, displays it and gives the user feedback.
The user can choose to continue, and get another question, or to exit the program.

After every response, some basic statistics are displayed and saved to the database.

When a certain question is answered correctly a consecutive number of times, it is considered mastered and won't be selected again for display.


![demo gif](demo.gif)

# Prerequisites:

* a terminal with `zsh` shell
* `sqlite3`


# Getting started:

1. clone this repo to your machine
2. `cd` into the cloned directory
3. add execute permissions: `sudo chmod +x quiz_runner.sh` 
4. run `./quiz_runner.sh`

this should display a quiz on the terminal.


# DB table description:
The default DB is created according to the following schemas:
```sql
CREATE TABLE items(iid integer primary key, stem text not null, ans1 text, ans2 text, ans3 text, ans4 text);
CREATE TABLE keys(iid integer not null, key string not null, foreign key (iid) references items (iid));
CREATE TABLE stats(iid integer not null, attempts integer not null, rights integer not null, streak integer not null, mastered boolean not null, foreign key (iid) references items (iid));
CREATE TABLE domains(did integer primary key, title text not null);
CREATE TABLE items_domains(iid integer not null, did integer not null, foreign key (iid) references items (iid), foreign key (did) references domains (did));
```

These tables are outlined bellow:

### items
* `iid` - item id
* `stem` - the question body, without the answer options
* `ans1` - answer option 1
* `ans2` - answer option 2
* `ans3` - answer option 3
* `ans4` - answer option 4

### keys
* `iid` - item id
* `key` - correct answer index (a|b|c|d)

### stats
* `iid` - item id
* `attemts` - total number of answer attempts
* `rights` - total number of correct answers
* `streak` - number of consecutive correct answers. incremented by 1 upon correct answer; set to 0 otherwise.
* `mastered` - if `streak` reaches predefined threshold (defined as `MASTERED_THRESHOLD` in `quiz_runner.sh`, the question is considered mastered, and won't show again.

### domains
* `did` - domain id
* `title` - domain name

### items_domains
* `iid` - item id
* `did` - domain id


# utils directory

The utils directory contains utility scripts such as reset all statistics, show the number of questions from each topic, wipe off all db content, etc.
To execute a script form utils:
 
1. add execute permissions: `sudo chmod +x utils/util_name.sh` (where `util_name` is the actual name of the util, as detailed bellow). 
2. run `utils/util_name.sh`

### util scripts

* `db_overview.sh` - print question distrubution by topic in the database
* `reset_stats.sh` - reset all statistics (number of trials, streaks, mastered etc.) 
* `empty_all_tables.sh` - wipe off all database content, leaving only empty tables. USE WITH CAUTION!. THIS OPERATION CANNOT BE UNDONE.


# Creating custom database content

If you'd like to replace the content of the default database that comes with the clone, wipe-off all database content, using the `empty_all_tables.sh` from the utils directory, and then popultate the tables with your own content, using the schemas as detailed above.

* note: run the utils script from the main directory, like so: `utils/empty_all_tables.sh`.


# Features that I may add in the future:
* Shuffle answers - anytime a question appears, its answer options are displayed in a random order
* Show questions by topic
* Ageing algorithm - display questions of least success level. i.e, you will see the questions you struggle with the most again and again. As the streak of a question is incremented, the
proirity of that question is lowered, in favor of harder questions (with lower streak level). This technique makes learning more efficient.
