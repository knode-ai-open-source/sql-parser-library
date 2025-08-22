## 08/22/2025

**Modernize SQL Parser Library build system, licensing, and tests**

---

## Summary

This PR refactors the **SQL Parser Library** with a new multi-variant CMake build, unified tooling, updated SPDX/licensing headers, simplified documentation, and a modernized test/coverage framework.

---

## Key Changes

### 🔧 Build & Tooling

* **Removed** legacy changelog/config files:

    * `.changes/*`, `.changie.yaml`, `CHANGELOG.md`, `build_install.sh`.
* **Added** `build.sh`:

    * Commands: `build`, `install`, `coverage`, `clean`.
    * Coverage integration with `llvm-cov`.
* `.gitignore`: added new build dirs (`build-unix_makefiles`, `build-cov`, `build-coverage`).
* **BUILDING.md**:

    * Updated for *SQL Parser Library v0.0.1*.
    * Explicit dependency steps (`a-memory-library`, `the-macro-library`).
    * Modern Dockerfile instructions.
* **Dockerfile**:

    * Ubuntu base image with configurable CMake.
    * Non-root `dev` user.
    * Builds/install deps (`a-memory-library`, `the-macro-library`) and this project.

### 📦 CMake

* Raised minimum version to **3.20**.
* Project renamed to `sql_parser_library` (underscore convention).
* **Multi-variant builds**:

    * `debug`, `memory`, `static`, `shared`.
    * Umbrella alias: `sql_parser_library::sql_parser_library`.
* Coverage toggle (`A_ENABLE_COVERAGE`) and memory profiling define (`_AML_DEBUG_`).
* Dependencies:

    * `a_memory_library`, `the_macro_library`.
* Proper **install/export**:

    * Generates `sql_parser_libraryConfig.cmake` + version file.
    * Namespace: `sql_parser_library::`.

### 📖 Documentation

* **AUTHORS**: updated Andy Curtis entry with GitHub profile.
* **NOTICE**:

    * Simplified: explicit copyright lines.
    * Attribution: Andy Curtis (2025), Knode.ai (2024–2025).
    * Legacy MIT-licensed portions no longer duplicated in notice (covered in LICENSE).

### 📝 Source & Headers

* SPDX headers updated:

    * En-dash years (`2024–2025`).
    * Andy Curtis explicitly credited.
    * Knode.ai marked with “technical questions” contact.
* Removed redundant `Maintainer:` lines.
* Cleanups:

    * Consistent header guards and `#endif` comments.
    * Fixed trailing newlines across `.c` files.

### ✅ Tests

* **`tests/CMakeLists.txt`**:

    * Modernized with variant-aware linking.
    * Coverage aggregation with `llvm-profdata` + `llvm-cov` (HTML + console).
* **`tests/build.sh`**:

    * Supports variants (`debug|memory|static|shared|coverage`).
    * Auto job detection.
* Test sources (`json_sql.c`, `sql_driver.c`, `sql_parser*.c`):

    * SPDX/licensing headers updated.
    * Code unchanged except for cleanup (consistent endings).

---

## Impact

* 🚀 Streamlined builds via `build.sh` and modern CMake variants.
* 🛡️ Clean, consistent SPDX licensing across all files.
* 📖 Documentation and NOTICE simplified.
* ✅ Stronger test + coverage workflow for CI integration.
