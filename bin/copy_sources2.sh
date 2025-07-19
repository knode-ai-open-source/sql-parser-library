bin/cat_source.sh `ls include/*/sql_types.h src/sql_[bdfis]*.c src/sql_types.c` > sources.txt

cat sources.txt | pbcopy
