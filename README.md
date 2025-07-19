# SQL Parser README

Here is a sample output

```
# ./sql_parser " select id from documents where id = 1 and 6 between 5 and 50 and (5+3+7*5.3 > 40 or 30 < age or age is null or age is not null) and created > '2021-12-21+0800' "
>> Tokens:

0 [KEYWORD] select
1 [IDENTIFIER] id
2 [KEYWORD] from
3 [IDENTIFIER] documents
4 [KEYWORD] where
5 [IDENTIFIER] id
6 [COMPARISON] =
7 [NUMBER] 1
8 [AND] and
9 [NUMBER] 6
10 [COMPARISON] between
11 [NUMBER] 5
12 [AND] and
13 [NUMBER] 50
14 [AND] and
15 [OPEN_PAREN] (
16 [NUMBER] 5
17 [OPERATOR] +
18 [NUMBER] 3
19 [OPERATOR] +
20 [NUMBER] 7
21 [OPERATOR] *
22 [NUMBER] 5.3
23 [COMPARISON] >
24 [NUMBER] 40
25 [OR] or
26 [NUMBER] 30
27 [COMPARISON] <
28 [IDENTIFIER] age
29 [OR] or
30 [IDENTIFIER] age
31 [KEYWORD] is
32 [NULL] null
33 [OR] or
34 [IDENTIFIER] age
35 [KEYWORD] is
36 [NOT] not
37 [NULL] null
38 [CLOSE_PAREN] )
39 [AND] and
40 [IDENTIFIER] created
41 [COMPARISON] >
42 [LITERAL] 2021-12-21+0800


>> AST Tree:

[KEYWORD] ROOT (DataType: UNKNOWN)
  [KEYWORD] select (DataType: UNKNOWN)
    [IDENTIFIER] id (DataType: INT)
  [KEYWORD] from (DataType: UNKNOWN)
    [IDENTIFIER] documents (DataType: INT)
  [KEYWORD] where (DataType: UNKNOWN)
    [AND] and (DataType: BOOL)
      Left:
        [AND] and (DataType: BOOL)
          Left:
            [AND] and (DataType: BOOL)
              Left:
                [COMPARISON] = (DataType: BOOL)
                  Left:
                    [IDENTIFIER] id (DataType: INT)
                  Right:
                    [NUMBER] 1 (DataType: INT)
              Right:
                [COMPARISON] BETWEEN (DataType: BOOL)
                  Expression:
                    [NUMBER] 6 (DataType: INT)
                  Lower Bound:
                    [NUMBER] 5 (DataType: INT)
                  Upper Bound:
                    [NUMBER] 50 (DataType: INT)
          Right:
            [OR] or (DataType: BOOL)
              Left:
                [OR] or (DataType: BOOL)
                  Left:
                    [OR] or (DataType: BOOL)
                      Left:
                        [COMPARISON] < (DataType: BOOL)
                          Left:
                            [NUMBER] 40 (DataType: INT)
                          Right:
                            [OPERATOR] + (DataType: UNKNOWN)
                              Left:
                                [OPERATOR] + (DataType: UNKNOWN)
                                  Left:
                                    [NUMBER] 5 (DataType: INT)
                                  Right:
                                    [NUMBER] 3 (DataType: INT)
                              Right:
                                [OPERATOR] * (DataType: UNKNOWN)
                                  Left:
                                    [NUMBER] 7 (DataType: INT)
                                  Right:
                                    [NUMBER] 5.3 (DataType: DOUBLE)
                      Right:
                        [COMPARISON] < (DataType: BOOL)
                          Left:
                            [NUMBER] 30 (DataType: INT)
                          Right:
                            [IDENTIFIER] age (DataType: INT)
                  Right:
                    [KEYWORD] IS NULL (DataType: BOOL)
                      [IDENTIFIER] age (DataType: INT)
              Right:
                [KEYWORD] IS NOT NULL (DataType: BOOL)
                  [IDENTIFIER] age (DataType: INT)
      Right:
        [COMPARISON] < (DataType: BOOL)
          Left:
            [LITERAL] 2021-12-21+0800 (DataType: STRING)
          Right:
            [IDENTIFIER] created (DataType: DATETIME)


>> WHERE clause as function tree before simplification:

Type: AND, Value: and, DataType: BOOL, Func: AND
  Type: AND, Value: and, DataType: BOOL, Func: AND
    Type: AND, Value: and, DataType: BOOL, Func: AND
      Type: COMPARISON, Value: =, DataType: BOOL, Func: == (int)
        Type: IDENTIFIER, Value: id, DataType: INT, Func: NULL
        Type: NUMBER, Value: 1, DataType: INT, Func: NULL
      Type: COMPARISON, Value: BETWEEN, DataType: BOOL, Func: BETWEEN (int)
        Type: NUMBER, Value: 6, DataType: INT, Func: NULL
        Type: NUMBER, Value: 5, DataType: INT, Func: NULL
        Type: NUMBER, Value: 50, DataType: INT, Func: NULL
    Type: OR, Value: or, DataType: BOOL, Func: OR
      Type: OR, Value: or, DataType: BOOL, Func: OR
        Type: OR, Value: or, DataType: BOOL, Func: OR
          Type: COMPARISON, Value: <, DataType: BOOL, Func: < (double)
            Type: FUNCTION, Value: CONVERT, DataType: DOUBLE, Func: convert_int_to_double
              Type: NUMBER, Value: 40, DataType: INT, Func: NULL
            Type: OPERATOR, Value: +, DataType: DOUBLE, Func: + (double)
              Type: FUNCTION, Value: CONVERT, DataType: DOUBLE, Func: convert_int_to_double
                Type: OPERATOR, Value: +, DataType: INT, Func: + (int)
                  Type: NUMBER, Value: 5, DataType: INT, Func: NULL
                  Type: NUMBER, Value: 3, DataType: INT, Func: NULL
              Type: OPERATOR, Value: *, DataType: DOUBLE, Func: * (double)
                Type: FUNCTION, Value: CONVERT, DataType: DOUBLE, Func: convert_int_to_double
                  Type: NUMBER, Value: 7, DataType: INT, Func: NULL
                Type: NUMBER, Value: 5.3, DataType: DOUBLE, Func: NULL
          Type: COMPARISON, Value: <, DataType: BOOL, Func: < (int)
            Type: NUMBER, Value: 30, DataType: INT, Func: NULL
            Type: IDENTIFIER, Value: age, DataType: INT, Func: NULL
        Type: KEYWORD, Value: IS NULL, DataType: BOOL, Func: IS NULL
          Type: IDENTIFIER, Value: age, DataType: INT, Func: NULL
      Type: KEYWORD, Value: IS NOT NULL, DataType: BOOL, Func: IS NOT NULL
        Type: IDENTIFIER, Value: age, DataType: INT, Func: NULL
  Type: COMPARISON, Value: <, DataType: BOOL, Func: < (datetime)
    Type: FUNCTION, Value: CONVERT, DataType: DATETIME, Func: convert_string_to_datetime
      Type: LITERAL, Value: 2021-12-21+0800, DataType: STRING, Func: NULL
    Type: IDENTIFIER, Value: created, DataType: DATETIME, Func: NULL


>> WHERE clause as function tree after simplification:

Type: AND, Value: and, DataType: BOOL, Func: AND
  Type: AND, Value: and, DataType: BOOL, Func: AND
    Type: AND, Value: and, DataType: BOOL, Func: AND
      Type: COMPARISON, Value: =, DataType: BOOL, Func: == (int)
        Type: IDENTIFIER, Value: id, DataType: INT, Func: NULL
        Type: NUMBER, Value: 1, DataType: INT, Func: NULL
      Type: LITERAL, Value: true, DataType: BOOL, Func: NULL
    Type: OR, Value: or, DataType: BOOL, Func: OR
      Type: OR, Value: or, DataType: BOOL, Func: OR
        Type: OR, Value: or, DataType: BOOL, Func: OR
          Type: LITERAL, Value: true, DataType: BOOL, Func: NULL
          Type: COMPARISON, Value: <, DataType: BOOL, Func: < (int)
            Type: NUMBER, Value: 30, DataType: INT, Func: NULL
            Type: IDENTIFIER, Value: age, DataType: INT, Func: NULL
        Type: KEYWORD, Value: IS NULL, DataType: BOOL, Func: IS NULL
          Type: IDENTIFIER, Value: age, DataType: INT, Func: NULL
      Type: KEYWORD, Value: IS NOT NULL, DataType: BOOL, Func: IS NOT NULL
        Type: IDENTIFIER, Value: age, DataType: INT, Func: NULL
  Type: COMPARISON, Value: <, DataType: BOOL, Func: < (datetime)
    Type: LITERAL, Value: 2021-12-20T16:00:00, DataType: DATETIME, Func: NULL
    Type: IDENTIFIER, Value: created, DataType: DATETIME, Func: NULL


>> WHERE clause as function tree after logical expressions simplification:

Type: AND, Value: and, DataType: BOOL, Func: AND
  Type: COMPARISON, Value: =, DataType: BOOL, Func: == (int)
    Type: IDENTIFIER, Value: id, DataType: INT, Func: NULL
    Type: NUMBER, Value: 1, DataType: INT, Func: NULL
  Type: COMPARISON, Value: <, DataType: BOOL, Func: < (datetime)
    Type: LITERAL, Value: 2021-12-20T16:00:00, DataType: DATETIME, Func: NULL
    Type: IDENTIFIER, Value: created, DataType: DATETIME, Func: NULL
```


## Third-Party Code

This project includes portions of code from the [brutezone](https://github.com/gregjesl/brutezone) project, which is licensed under the MIT License. 

### Included Files
The following files have been adapted or included from the brutezone project:
- `src/brutezone/timezone.c`
- `src/brutezone/timezone_impl.c`
- `include/sql-parser-library/brutezone/timezone.h`
- `include/sql-parser-library/brutezone/timezone_database.h`
- `include/sql-parser-library/brutezone/timezone_impl.h`

### License
The brutezone project is licensed under the MIT License. A copy of the license is provided in the `third_party/brutezone/LICENSE` file.