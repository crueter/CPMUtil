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

# paths
cmake_path(GET pkg_cache_abs PARENT_PATH pkg_cache_parent)
cmake_path(GET pkg_cache_abs FILENAME pkg_cache_name)

if (EXISTS ${pkg_cache_abs})
    file(REMOVE_RECURSE ${pkg_cache_abs})
    echo("Removed ${pkg_cache_abs}")
endif()

# Temporary directory.
mktempdir(TMP)

# Get download URL.
get_url()

# Destination
set(file ${TMP}/${pkg_url_filename})
set(dir ${TMP}/${pkg_url_filename}-extracted)
file(MAKE_DIRECTORY ${dir})

# Now download
download(${pkg_url} ${file} ${hash})
echo("Downloaded ${pkg_url_filename} to ${TMP}")

# Extract the downloaded archive
# TODO: Error handling
file(ARCHIVE_EXTRACT
    INPUT ${file}
    DESTINATION ${dir})

# TODO: Patches

# This is copied near-verbatim from ExternalProject/extractfile.cmake.in

# If there's just one subdirectory and nothing else, move it
file(GLOB contents "${dir}/*")
list(REMOVE_ITEM contents "${dir}/.DS_Store")
list(LENGTH contents n)

# If n == 1 and contents points to a directory, this is a GitHub-style pack
# In this case contents points to the subdir which will get renamed
# If not, contents will point to the parent dir which will get renamed
if (NOT n EQUAL 1 OR NOT IS_DIRECTORY "${contents}")
    set(contents "${dir}")
endif()

file(REAL_PATH "${contents}" contents_abs)

# rename tmp dir
set(tmp_renamed "${TMP}/${pkg_cache_name}")
file(RENAME "${contents_abs}" "${tmp_renamed}")

# now copy
# TODO: Error handling beyond what cmake does????
file(COPY ${tmp_renamed} DESTINATION ${pkg_cache_parent})

# done! :)
echo("Extracted to ${pkg_cache_abs}")

file(REMOVE_RECURSE ${TMP})