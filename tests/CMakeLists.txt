# SPDX-FileCopyrightText: 2024-2025 Knode.ai
# SPDX-License-Identifier: Apache-2.0
# Maintainer: Andy Curtis <contactandyc@gmail.com>
cmake_minimum_required(VERSION 3.10)
project(search_builder_example VERSION 1.0)

# Enable testing
enable_testing()

# Define the library to test
set(LIB_TO_TEST sql-parser-library)

# Set the directory for test sources
set(TEST_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/sql_parser.c ${CMAKE_CURRENT_SOURCE_DIR}/src/sql_driver.c)

set(CUSTOM_PACKAGES a-json-library a-memory-library the-macro-library)

find_package(a-cmake-library REQUIRED)

include(BinaryConfig)
