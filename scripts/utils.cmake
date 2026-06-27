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

# Analogous to POSIX echo, but to stderr
macro(echo_error)
    string(REPLACE ";" " " message "${ARGN}")
    message(NOTICE "${message}")
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

    echo_error("Fatal: Could not create temporary directory. "
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
    list(LENGTH ARGN argn_len)
    if(argn_len GREATER 0)
        list(GET ARGN 0 hash)
        set(args EXPECTED_HASH SHA512=${hash})
    endif()

    foreach(i RANGE 5)
        file(DOWNLOAD ${url} ${file}
            ${args}
            STATUS ret
            LOG log)

        list(GET ret 0 code)
        if (code EQUAL 0)
            break()
        endif()

        echo_error("Download attempt ${i} failed: ${log}\n"
            "Trying again in 5 seconds")
        sleep(5)
    endforeach()

    # TODO: use return code or something
    if (NOT code EQUAL 0)
        echo_error("Fatal: Download for ${pkg_url} failed after 5 tries")
        cmake_language(EXIT 1)
    endif()
endfunction()

# Wrapper around find_program that works with Git for Windows
macro(cpm_find_program)
    # Windows needs additional paths for some utilities.
    if (CMAKE_HOST_WIN32)
        find_package(Git QUIET)
        if(GIT_EXECUTABLE)
            # Search within the Git for Windows paths.
            get_filename_component(extra_search_path
                ${GIT_EXECUTABLE} DIRECTORY)
            get_filename_component(extra_search_path_1up
                ${extra_search_path} DIRECTORY)
            get_filename_component(extra_search_path_2up
                ${extra_search_path_1up} DIRECTORY)

            set(base_hints "${extra_search_path_1up}/usr/bin"
                "${extra_search_path_2up}/usr/bin")

            # Also add core_perl to the paths, for perl commands like json_pp
            set(hints "")
            foreach(hint ${base_hints})
                list(APPEND hints
                    "${hint}"
                    "${hint}/core_perl")
            endforeach()

            find_program(${ARGN} HINTS ${hints})
            return()
        endif()

        # If no Git is found, continue as normal
    endif()

    find_program(${ARGN})
endmacro()

# Format the cpmfile. Requires one of: jq, python, perl
# If you don't have any of those, sorry not sorry.
# Maybe I should make a shell-based alternative.
function(format_cpmfile)
    # jq is the preferred formatter since it's the fastest
    cpm_find_program(JQ_EXECUTABLE jq)
    if (JQ_EXECUTABLE)
        set(command ${JQ_EXECUTABLE} --indent 4 -S .)
    else()
        # Python is simple and works
        find_package(Python 3.5 COMPONENTS Interpreter QUIET)
        if (Python_FOUND)
            set(command ${Python_EXECUTABLE} -m json.tool
                --indent 4 --sort-keys)
        else()
            # json_pp (part of perl) also works well
            cpm_find_program(JSONPP_EXECUTABLE json_pp)
            if (JSONPP_EXECUTABLE)
                set(json_opts "indent" "indent_length=4" "canonical"
                    "space_after=1" "space_before=0")
                string(JOIN "," json_opts_str ${json_opts})
                set(command ${JSONPP_EXECUTABLE} -f json -t json -json_opt
                    "${json_opts_str}")
            else()
                echo_error("Fatal: could not find one of jq, Python, or perl"
                    "(json_pp). Install one of these packages to use"
                    "CPMUtil's tooling. If they ARE installed, your"
                    "CMake installation is broken.")
                cmake_language(EXIT 1)
            endif()
        endif()
    endif()

    get_cpmfile_path(file)
    mktempdir(TMP)
    set(tmp_file ${TMP}/cpmfile.json)

    execute_process(COMMAND ${command}
        INPUT_FILE ${file}
        OUTPUT_FILE ${tmp_file})

    # TODO: error handling, mv, cp?
    file(COPY_FILE ${tmp_file} ${file})

    file(REMOVE_RECURSE ${TMP})
endfunction()