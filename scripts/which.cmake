#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/)
include(utils)

# Check if a key exists
get_cpmfile_content(object)

set(key discord-rpc)
string(JSON member ERROR_VARIABLE err GET "${object}" ${key})

if (NOT err)
    echo("${key}")
    cmake_language(EXIT 0)
else()
    echo_error("${key} not defined in cpmfile")
    cmake_language(EXIT 1)
endif()