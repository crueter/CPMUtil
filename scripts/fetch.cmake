#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(utils)

parse_key(discord-rpc)

# TODO: Handle CI packages

# Get cache path.
get_cache_path()

# Early exit if cache path already exists and is nonempty
# TODO: patch key
if (EXISTS ${pkg_cache_path})
    echo("Directory ${pkg_cache_path} already exists")
    cmake_language(EXIT 0)
endif()

# Temporary directory.
mktempdir(TMP)

# Get download URL.
get_url()

# Destination
set(file ${TMP}/${pkg_url_filename})

# Now download
download(${pkg_url} ${file} ${hash})
echo("Downloaded ${pkg_url_filename} to ${TMP}")

# Construct and create cache path
get_cache_path()
file(MAKE_DIRECTORY ${pkg_cache_path})

# Extract the downloaded archive
file(ARCHIVE_EXTRACT
    INPUT ${file}
    DESTINATION ${pkg_cache_path})

# TODO: Patches

# done! :)
file(REAL_PATH ${pkg_cache_path} abs_path)
echo("Extracted to ${abs_path}")

file(REMOVE_RECURSE ${TMP})