# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

#!/usr/bin/env -S cmake -P
cmake_minimum_required(VERSION 3.31)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/..)
set(CPMUTIL_ROOT ${CMAKE_CURRENT_LIST_DIR}/../tests)
include(CPMUtil)

get_json_object(discord-rpc)
set(JSON_NAME discord-rpc)
parse_object(${object})

# TODO: Handle CI packages

macro(echo)
    string(REPLACE ";" " " message "${ARGN}")
    execute_process(COMMAND ${CMAKE_COMMAND} -E echo
        "${message}")
endmacro()

macro(sleep time)
    execute_process(COMMAND ${CMAKE_COMMAND} -E sleep ${time})
endmacro()

function(mktempdir out)
    # shell out to system mktemp if available
    find_program(MKTEMP_EXECUTABLE mktemp)
    if (MKTEMP_EXECUTABLE)
        execute_process(COMMAND mktemp -d
            OUTPUT_VARIABLE dir
            OUTPUT_STRIP_TRAILING_WHITESPACE
            RESULT_VARIABLE ret)

        if (ret EQUAL 0)
            set(${out} "${dir}" PARENT_SCOPE)
            return()
        endif()
    endif()

    string(RANDOM LENGTH 10 rand_str)
    set(tmp_str "tmp.${rand_str}")

    # create something in /tmp if it exists
    if(EXISTS "/tmp" AND IS_DIRECTORY "/tmp")
        set(dir "/tmp/${tmp_str}")
        file(MAKE_DIRECTORY "${dir}" RESULT res)
        if (res EQUAL 0)
            set(${out} "${dir}" PARENT_SCOPE)
            return()
        endif()
    endif()

    # tmpdir does not exist, extremely legacy mode
    set(dir "${CMAKE_CURRENT_LIST_DIR}/.tmp/${tmp_str}")
    file(MAKE_DIRECTORY "${dir}" RESULT res)
    if (res EQUAL 0)
        set(${out} "${dir}" PARENT_SCOPE)
        return()
    endif()

    echo("Fatal: Could not create temporary directory. "
        "Check write permissions to the current directory")
    cmake_language(EXIT 1)
endfunction()

# TODO: Move this to a util function.
if(DEFINED sha)
    string(SUBSTRING ${sha} 0 4 pkg_key)
else()
    set(pkg_key ${version})
endif()

# TODO: Move this to a util function.
if(NOT DEFINED git_host)
    set(git_host github.com)
endif()

if(DEFINED url)
    set(pkg_url ${pkg_url})
elseif(DEFINED repo)
    set(pkg_git_url https://${git_host}/${repo})

    if(DEFINED sha)
        set(pkg_url "${pkg_git_url}/archive/${sha}.tar.gz")
    elseif(DEFINED tag)
        set(tag "${tags}")
        if(DEFINED artifact)
            set(pkg_url
                "${pkg_git_url}/releases/download/${tag}/${artifact}")
        else()
            set(pkg_url
                "${pkg_git_url}/archive/refs/tags/${tag}.tar.gz")
        endif()
    endif()
else()
    cpm_utils_message(FATAL_ERROR
        "${package}: No URL or repository defined")
endif()

# Early exit if cache path already exists and is nonempty
# TODO: patch key
if (EXISTS ${cache_path})
    echo("Directory ${cache_path} already exists")
    cmake_language(EXIT 0)
endif()

# Download

# TODO: util function
# retry 5 times
macro(download url file hash)
    foreach(i RANGE 5)
        file(DOWNLOAD ${url} ${file}
            EXPECTED_HASH SHA512=${hash}
            STATUS ret
            LOG log)

        list(GET ret 0 code)
        if (code EQUAL 0)
            break()
        endif()

        echo("Download attempt ${i} failed: ${log}\nTrying again in 5 seconds")
        sleep(5)
    endforeach()

    if (NOT code EQUAL 0)
        echo("Fatal: Download for ${pkg_url} failed after 5 tries")
        cmake_language(EXIT 1)
    endif()
endmacro()

mktempdir(TMP)

get_filename_component(filename ${pkg_url} NAME)
set(file ${TMP}/${filename})

download(${pkg_url} ${file} ${hash})

echo("Downloaded ${filename} to ${TMP}")

# Construct and create cache path
string(TOLOWER ${package} lower_name)

# TODO: Figure out a sln to CPM_SOURCE_CACHE; CPMConfig.cmake?
set(rel_cache_path ${CPM_SOURCE_CACHE}/${lower_name}/${pkg_key})
file(MAKE_DIRECTORY ${rel_cache_path})
file(REAL_PATH ${rel_cache_path} cache_path)

# Extract the downloaded archive
file(ARCHIVE_EXTRACT
    INPUT ${file}
    DESTINATION ${cache_path})

# TODO: Patches

echo("Extracted to ${cache_path}")