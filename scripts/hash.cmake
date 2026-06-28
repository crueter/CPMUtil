#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(utils)

set(key discord-rpc)
parse_key("${key}")

get_package_hash(pkg_hash)

option(CORRECT_HASH "Correct hash if it's mismatched" OFF)

if (pkg_hash STREQUAL hash)
    echo("Hashes match")
else()
    echo_error("Hash mismatch")
    echo_error("Expected: ${hash}")
    echo_error("Got:      ${pkg_hash}")

    if (CORRECT_HASH)
        set_package_hash("${object}" "${key}" ${pkg_hash}"")
    else()
        cmake_language(EXIT 1)
    endif()
endif()