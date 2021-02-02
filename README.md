# Prerequisits:

* a terminal with `zsh` interpreter
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
5. populate the tables with your own content
