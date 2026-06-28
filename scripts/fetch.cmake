#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(utils)

set(key discord-rpc)
parse_key(${key})

# TODO: Handle CI packages

# Get cache path.
get_cache_path()

# patch keys
compute_patch_key("${patches}" patch_key)
needs_refetch(${pkg_cache_path} "${patch_key}" CACHE_INVALID)

if (CACHE_INVALID)
    echo("Cache for ${key} is missing or invalid")
    file(REMOVE_RECURSE ${pkg_cache_path})
else()
    echo("Cache for ${key} is up-to-date")
    cmake_language(EXIT 0)
endif()

get_url()
fetch_package("${pkg_url}" "${hash}" "${pkg_cache_path}" "${patch_key}")