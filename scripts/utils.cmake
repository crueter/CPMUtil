#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/..)
set(CPMUTIL_ROOT ${CMAKE_CURRENT_LIST_DIR}/../tests)

include(CPMUtil)

# Parse the JSON object for a given key.
macro(parse_key key)
    get_json_object(discord-rpc)
    set(JSON_NAME discord-rpc)
    parse_object(${object})
endmacro()

# Analogous to POSIX echo
macro(echo)
    string(REPLACE ";" " " message "${ARGN}")
    execute_process(COMMAND ${CMAKE_COMMAND} -E echo
        "${message}")
endmacro()

# Analogous to POSIX sleep
macro(sleep time)
    execute_process(COMMAND ${CMAKE_COMMAND} -E sleep ${time})
endmacro()

# Analogous to GNU mktemp, with fallbacks
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

# Get a package's effective URL. Outputs to "pkg_url"
# The URL's filename is output to "pkg_url_filename"
# Requires an object to already be parsed (TODO)
function(get_url)
    if(NOT DEFINED git_host)
        set(git_host github.com)
    endif()

    if(DEFINED url)
        set(pkg_url ${url})
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

    get_filename_component(pkg_url_filename ${pkg_url} NAME)

    return(PROPAGATE pkg_url pkg_url_filename)
endfunction()

# Get a package's cache key. Outputs to "pkg_key"
# Requires an object to already be parsed (TODO)
function(get_cache_key)
    if(DEFINED sha)
        string(SUBSTRING ${sha} 0 4 pkg_key)
    else()
        set(pkg_key ${version})
    endif()
    return(PROPAGATE pkg_key)
endfunction()

# Get a package's cache path. Outputs to "pkg_cache_path"
# Requires an object to already be parsed (TODO)
function(get_cache_path)
    if (NOT DEFINED pkg_key)
        get_cache_key()
    endif()

    # Construct cache path
    string(TOLOWER ${package} lower_name)

    # TODO: Figure out a sln to CPM_SOURCE_CACHE; CPMConfig.cmake?
    set(pkg_cache_path ${CPM_SOURCE_CACHE}/${lower_name}/${pkg_key})

    return(PROPAGATE pkg_cache_path)
endfunction()

# Download a URL to file, with a sha512 hash
# And retry 5 times
function(download url file hash)
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

    # TODO: use return code or something
    if (NOT code EQUAL 0)
        echo("Fatal: Download for ${pkg_url} failed after 5 tries")
        cmake_language(EXIT 1)
    endif()
endfunction()

# Format the cpmfile. Requires jq
function(format_cpmfile)
    find_program(JQ_EXECUTABLE jq)
    if (NOT JQ_EXECUTABLE)
        echo("Warning: jq not found, JSON formatting unavailable")
        return()
    endif()

    get_cpmfile_path(file)
    mktempdir(TMP)
    set(tmp_file ${TMP}/cpmfile.json)

    execute_process(COMMAND ${JQ_EXECUTABLE} --indent 4 -S . ${file}
        OUTPUT_FILE ${tmp_file})

    # TODO: error handling, mv, cp?
    file(COPY_FILE ${tmp_file} ${file})

    file(REMOVE_RECURSE ${TMP})
endfunction()