#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(utils)

parse_key(discord-rpc)

# TODO: This is a near exact copy of fetch.cmake
# TODO: Handle CI packages

# Get cache path.
get_cache_path()

# Early exit if cache path already exists and is nonempty
# TODO: patch key
cmake_path(ABSOLUTE_PATH pkg_cache_path NORMALIZE OUTPUT_VARIABLE pkg_cache_abs)

if (EXISTS ${pkg_cache_abs})
    file(REMOVE_RECURSE ${pkg_cache_abs})
    echo("Removed ${pkg_cache_abs}")
endif()

fetch_package()
