#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(utils)

set(key discord-rpc)
parse_key(${key})

if (ci)
    echo_error("CI packages can't be prefetched")
    cmake_language(EXIT 1)
endif()

fetch_package_object(FORCE)
