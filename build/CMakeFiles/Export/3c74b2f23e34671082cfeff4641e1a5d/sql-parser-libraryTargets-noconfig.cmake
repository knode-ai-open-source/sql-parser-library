#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "sql-parser-library::static" for configuration ""
set_property(TARGET sql-parser-library::static APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(sql-parser-library::static PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_NOCONFIG "C"
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libsql-parser-library_static.a"
  )

list(APPEND _cmake_import_check_targets sql-parser-library::static )
list(APPEND _cmake_import_check_files_for_sql-parser-library::static "${_IMPORT_PREFIX}/lib/libsql-parser-library_static.a" )

# Import target "sql-parser-library::debug" for configuration ""
set_property(TARGET sql-parser-library::debug APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(sql-parser-library::debug PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_NOCONFIG "C"
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libsql-parser-library_debug.a"
  )

list(APPEND _cmake_import_check_targets sql-parser-library::debug )
list(APPEND _cmake_import_check_files_for_sql-parser-library::debug "${_IMPORT_PREFIX}/lib/libsql-parser-library_debug.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
