# bin/cat_source.sh `ls include/*/*.h src/*.c src/*/*.c` | pbcopy
bin/cat_source.sh `ls include/*/*.h demo/sql_parser.c src/sql_tokenizer.c src/sql_ast.c` > sources.txt

gcc demo/sql_parser.c src/*.c  src/*/*.c -Iinclude -o sql_parser -la-memory-library -Wl,-rpath,/usr/local/lib -g -O0 2>>sources.txt

echo '# ./sql_parser "' $1 '"' > command.txt
./sql_parser "$1" >> command.txt

cat command.txt

cat sources.txt command.txt | pbcopy
