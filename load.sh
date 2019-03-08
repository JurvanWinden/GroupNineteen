#!/bin/sh
# This script will create the tables and load all data. A sample template follows, but feel free to merge the two files.
# The script will be given 18 minutes and killed afterwards
# Expected size of tables after loading should be below 8 GB
# The total disk space available for storing all data, views, indices, and the write-ahead-log (also see UNLOGGED keyword) is 12 GB

psql -d uni -f createTables.sql
psql -d uni -f loadData.sql