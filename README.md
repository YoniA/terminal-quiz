# About

A simple bash script that displays random questions in terminal.

Upon invocation, the script queries a custom `sqlite` database for a random question, displays it and gives the user feedback.
The user can choose to continue, and get another question, or to exit the program.

After every response, some basic statistics are displayed and saved to the database.

When a certain question is answered correctly a consecutive number of times (defined in `quiz_runner.sh` as `MASTERED_THRESHOLD`), it is considered mastered and won't be selected again for display.


# Prerequisits:

* a terminal with `zsh` shell
* `sqlite3`


# Getting started:

1. clone this repo to your machine
2. `cd` into the cloned directory 
3. run `./quiz_runner.sh`

this should display a quiz on the terminal.

## Creating custom database content

If you'd like to replace the content of the default database that comes with the clone, you can do the following:
1. remove the default database: `rm -rf ./quiz.db`
2. in `mysqlite3` create an empty database named `quiz.db` (name is important!).
3. create tables according to the following schemas:

```sql
CREATE TABLE items(iid integer primary key, stem text not null, ans1 text, ans2 text, ans3 text, ans4 text);
CREATE TABLE keys(iid integer not null, key string not null, foreign key (iid) references items (iid));
CREATE TABLE stats(iid integer not null, attempts integer not null, rights integer not null, streak integer not null, mastered boolean not null, foreign key (iid) references items (iid));
CREATE TABLE domains(did integer primary key, title text not null);
CREATE TABLE items_domains(iid integer not null, did integer not null, foreign key (iid) references items (iid), foreign key (did) references domains (did));
```

4. activate foreign key constraints: `PRAGMA foreign_keys=ON;`
5. populate the tables with your own content (recommended with `sqlitebrowser`)


## Column names description:

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
* `mastered` - if `sterek` reaches predefined threshold, the question is considered mastered, and won't show again.

### domains
* `did` - domain id
* `title` - domain name

### items_domains
* `iid` - item id
* `did` - domain id




