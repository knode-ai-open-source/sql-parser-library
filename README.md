# sql-parser-library

> A lightweight C library for tokenizing, parsing, simplifying, and evaluating (selected) SQL expressions with pluggable function specifications.

---

## Table of Contents

1. [Goals & Scope](#goals--scope)
2. [Core Concepts](#core-concepts)
3. [Architecture Overview](#architecture-overview)
4. [Data Types & Tokens](#data-types--tokens)
5. [Context (`sql_ctx_t`)](#context-sql_ctx_t)
6. [Function Specifications](#function-specifications)
7. [Tokenization](#tokenization)
8. [AST & Nodes](#ast--nodes)
9. [Intervals](#intervals)
10. [Evaluation Flow](#evaluation-flow)
11. [Type Handling & Conversion](#type-handling--conversion)
12. [Error & Warning Handling](#error--warning-handling)
13. [Registration Helpers](#registration-helpers)
14. [Usage Example](#usage-example)
15. [Extending the Library](#extending-the-library)
16. [Directory Layout](#directory-layout)
17. [License](#license)
18. [Attribution](#attribution)

---

## Goals & Scope

* Provide **tokenization** for SQL-like input strings.
* Build a simplified **AST** for expressions and clauses.
* Offer a normalized **node representation** (`sql_node_t`) for evaluation & transformation.
* Enable **extensible function registration** (arithmetic, aggregates, string/date/time, boolean, comparison, etc.).
* Support **type inference, conversion, and simplification** passes.
* Collect **errors & warnings** during parsing and evaluation.

*Not a full SQL engine*: Focused on expression parsing & limited clause discovery (e.g., locating specific clauses) rather than full query planning, execution, or storage.

---

## Core Concepts

| Concept                            | Purpose                                                                          |
| ---------------------------------- | -------------------------------------------------------------------------------- |
| *Token*                            | Lexical unit from input string.                                                  |
| *AST (`sql_ast_node_t`)*           | Lightweight syntax tree directly from tokens.                                    |
| *Node (`sql_node_t`)*              | Semantic/evaluable representation (typed, spec-bound).                           |
| *Context (`sql_ctx_t`)*            | Holds pools, registered functions, keywords, columns, messages.                  |
| *Spec (`sql_ctx_spec_t`)*          | Describes a function (name, description, update callback).                       |
| *Update (`sql_ctx_spec_update_t`)* | Normalization result: coerced param types, implementation callback, return type. |

---

## Architecture Overview

```
SQL Text --> Tokenizer --> Tokens --> AST Builder --> AST --> Node Converter --> sql_node_t Graph
                                                           |                         |
                                                           |                      Simplification
                                                           v                         (type conversions,
                                                 Clause Discovery                   logical folding)
                                                           |
                                                           v
                                                       Evaluation
```

Memory is managed via `aml_pool_t` (a pool allocator) passed through the context.

---

## Data Types & Tokens

### Token Types (`sql_token_type_t`)

Representative categories:

* Structural & punctuation: `SQL_OPEN_PAREN`, `SQL_CLOSE_PAREN`, `SQL_COMMA`, `SQL_SEMICOLON`, `SQL_OPEN_BRACKET`, `SQL_CLOSE_BRACKET`.
* Literals: `SQL_NUMBER`, `SQL_LITERAL`, `SQL_COMPOUND_LITERAL`, `SQL_NULL`, `SQL_LIST`.
* Identifiers & keywords: `SQL_IDENTIFIER`, `SQL_KEYWORD`, `SQL_FUNCTION`, `SQL_FUNCTION_LITERAL`, `SQL_STAR`.
* Operators & logic: `SQL_OPERATOR`, `SQL_COMPARISON`, `SQL_AND`, `SQL_OR`, `SQL_NOT`.
* Misc: `SQL_TOKEN`, `SQL_COMMENT`.

Helper: `const char *sql_token_type_name(sql_token_type_t type);`

### Data Types (`sql_data_type_t`)

`SQL_TYPE_INT`, `SQL_TYPE_STRING`, `SQL_TYPE_DOUBLE`, `SQL_TYPE_DATETIME`, `SQL_TYPE_BOOL`, `SQL_TYPE_FUNCTION`, `SQL_TYPE_CUSTOM`, with unknown fallback `SQL_TYPE_UNKNOWN`.
Helper: `const char *sql_data_type_name(sql_data_type_t type);`

---

## Context (`sql_ctx_t`)

Holds:

* `aml_pool_t *pool` memory arena.
* Column metadata (`sql_ctx_column_t *columns`, `column_count`).
* Time zone offset (`time_zone_offset`).
* Error & warning lists.
* Reserved keywords map.
* Callback registry (`named_pointer_t callbacks`).
* Registered function specs map.
* Optional `row` pointer (user data for evaluation callbacks).

Column entries: name, type, and a `sql_node_cb` accessor.

Utility API categories:

* **Messages**: add / fetch / print / clear errors & warnings.
* **Callbacks**: register / lookup / reverse lookup (name & description).
* **Keywords**: reserve & test reserved words.
* **Specs**: register & retrieve function specifications.

---

## Function Specifications

`sql_ctx_spec_t` supplies:

* `name`
* `description`
* `update` callback (`sql_ctx_update_cb`) producing a `sql_ctx_spec_update_t` that sets:

    * Expected parameter types & concrete parameter nodes
    * Return type
    * Implementation function pointer (`sql_node_cb`)

This layer allows late binding & normalization of function calls (e.g., implicit casts, argument list shaping).

---

## Tokenization

`sql_token_t` fields: `type`, `token` string, optional `spec` pointer (signals known function), origin offsets (`start`, `start_position`, `length`), and unique `id`.

API:

* `sql_token_t **sql_tokenize(sql_ctx_t *context, const char *s, size_t *token_count);`
* `void sql_token_print(sql_token_t **tokens, size_t token_count);`

---

## AST & Nodes

### AST (`sql_ast_node_t`)

Fields: token `type`, textual `value`, inferred `data_type`, optional top-level `spec`, plus `left`, `right` (binary ops), and `next` for sibling linking.

API:

* `build_ast(...)` builds AST from tokens.
* `print_ast(node, depth)` for debugging.
* `find_clause(root, clause_name)` to locate a clause subtree.

### Evaluable Node (`sql_node_t`)

Adds:

* Evaluation `func` pointer
* Unified `data_type` & value union (bool/int/double/string/datetime/custom)
* Parameter array (`parameters`, `num_parameters`)
* Function `spec`
* Nullability flag

Creation helpers: `sql_bool_init`, `sql_int_init`, `sql_double_init`, `sql_string_init`, `sql_compound_init`, `sql_datetime_init`, `sql_function_init`, `sql_list_init`.

Transform helpers: `convert_ast_to_node`, `apply_type_conversions`, `simplify_tree`, `simplify_func_tree`, `simplify_logical_expressions`, `copy_nodes`, `print_node`.

---

## Intervals

`sql_interval_t` captures granular temporal units (years → microseconds).
Parser: `sql_interval_t *sql_interval_parse(sql_ctx_t *context, const char *interval);`
Used to interpret compound time literals (e.g., `INTERVAL 1 DAY`).

---

## Evaluation Flow

1. **Initialize Context** (`sql_ctx_t ctx = {0}; register_ctx(&ctx);`).
2. **Register Additional Specs / Keywords** as needed.
3. **Tokenize** input SQL.
4. **Build AST** via `build_ast`.
5. **Convert AST → Nodes** (`convert_ast_to_node`).
6. **Apply Simplifications** (`simplify_tree`, `simplify_logical_expressions`, etc.).
7. **Bind / Update Functions** via spec `update` callbacks (during conversion / simplify phase).
8. **Evaluate** root with `sql_eval` (which invokes node `func` callbacks recursively).
9. **Inspect Messages** (errors/warnings) if evaluation failed or partial.

---

## Type Handling & Conversion

* Common type resolution: `sql_determine_common_type(type1, type2)`.
* Explicit or implicit conversion: `sql_convert(context, param, target_type)`.
* Batch pass: `apply_type_conversions` adjusts subtree to expected spec types.

---

## Error & Warning Handling

Emit messages during lexing, parsing, spec resolution, or evaluation using:

* `sql_ctx_error(ctx, "...")`
* `sql_ctx_warning(ctx, "...")`
  Retrieve & clear via: `sql_ctx_get_errors`, `sql_ctx_get_warnings`, `sql_ctx_print_messages`, `sql_ctx_clear_messages`.

Errors do **not** automatically abort tokenization or parsing; downstream phases should check presence before evaluation.

---

## Registration Helpers

Provided convenience registration functions (invoked by `register_ctx` inline helper) for built‑in spec sets:

* Arithmetic, boolean, comparison, BETWEEN, IN, LIKE, IS NULL / IS BOOLEAN
* String: `concat`, `length`, `lower_upper`, `substr`, `trim`
* Aggregates: `avg`, `min_max`, `sum`
* Date/Time: `convert_tz`, `date_trunc`, `extract`, `now`, `round` (numeric/date), `convert`
* Other: `coalesce`

Call any subset directly *or* use `register_ctx(&ctx)` to load all defaults plus default reserved keywords.

---

## Usage Example

```c
#include "sql-parser-library/sql_tokenizer.h"
#include "sql-parser-library/sql_ast.h"
#include "sql-parser-library/sql_ctx.h"

int main() {
    sql_ctx_t ctx = {0};
    register_ctx(&ctx); // load defaults

    const char *expr = "COALESCE(1 + 2, 0)";

    size_t token_count = 0;
    sql_token_t **tokens = sql_tokenize(&ctx, expr, &token_count);
    sql_token_print(tokens, token_count);

    sql_ast_node_t *ast = build_ast(&ctx, tokens, token_count);
    print_ast(ast, 0);

    sql_node_t *root = convert_ast_to_node(&ctx, ast);
    simplify_tree(&ctx, root);

    sql_node_t *result = sql_eval(&ctx, root);
    // Inspect result->data_type and union for value

    sql_ctx_print_messages(&ctx);
    return 0; // Pool cleanup strategy depends on aml_pool lifecycle
}
```

---

## Extending the Library

1. **Define a Spec**: Create a `sql_ctx_spec_t` with `name`, `description`, and `update` callback.
2. **Implement Update Callback**: Validate parameter count/types; build a `sql_ctx_spec_update_t` (allocate arrays in the context pool) specifying:

    * `expected_data_types[i]`
    * Normalized `parameters[i]` (possibly converted)
    * `return_type`
    * `implementation` (`sql_node_cb`) that computes a `sql_node_t *` when evaluated.
3. **Register** the spec with `sql_ctx_register_spec`.
4. **Use** the function in SQL text; tokenizer marks the token with `spec` enabling special handling later.

### Adding Reserved Keywords

Call `sql_ctx_reserve_keyword(&ctx, "MY_KEYWORD");` to prevent use as identifier.

### Adding Column Resolvers

Populate `ctx.columns` and set `column_count`; each `sql_ctx_column_t.func` should return a `sql_node_t *` representing the current row's column value.

---

## Directory Layout

```
include/
  sql-parser-library/
    sql_ast.h
    sql_ctx.h
    sql_interval.h
    sql_node.h
    sql_tokenizer.h
```

(Implementation source files would mirror these headers; not shown.)

---

## License

Apache-2.0 (see SPDX headers). Ensure any distribution retains existing SPDX notices.

---

## Attribution

Maintainer: **Andy Curtis [contactandyc@gmail.com](mailto:contactandyc@gmail.com)**
Copyright © 2024-2025 Knode.ai

---

## Status

Early-stage; API may evolve. Review headers for the authoritative contract until full semantic versioning is established.

---

**Enjoy building with *sql-parser-library*!**
