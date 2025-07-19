// SPDX-FileCopyrightText: 2024-2025 Knode.ai
// SPDX-License-Identifier: Apache-2.0
// Maintainer: Andy Curtis <contactandyc@gmail.com>
#ifndef _date_utils_H
#define _date_utils_H

#define _XOPEN_SOURCE 700
#include <time.h>
#include <stdbool.h>
#include "a-memory-library/aml_pool.h"

const char *get_timezone(const char *date_str);
int get_timezone_offset(const char *timezone_part);
bool convert_string_to_datetime(time_t *result, aml_pool_t *pool, const char *date_str);
char *convert_epoch_to_iso_utc(aml_pool_t *pool, time_t epoch);

#endif