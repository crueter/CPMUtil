#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(ScriptUtils)

parse_script_args(args)

foreach(key ${args})
    parse_key(${key})

    if (ci)
        echo_error("CI packages can't be prefetched")
        cmake_language(EXIT 1)
    endif()

    fetch_package_object()
endforeach()
