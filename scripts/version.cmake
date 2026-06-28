#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(utils)

set(key carboxyl)
parse_key("${key}")

if (NOT NEW_VERSION)
    echo_error("You must provide a version")
endif()

set(version ${NEW_VERSION})

get_package_hash(pkg_hash)
modify_package("${object}" "${key}" "${version}" "${pkg_hash}")
