#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

# TODO: Account for CPMConfig.cmake
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR})
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMakeModules)
set(CPMUTIL_ROOT ${CMAKE_SOURCE_DIR})

include(CPMUtil)

# Parse the JSON object for a given key.
macro(parse_key key)
    get_json_object(${key})
    set(JSON_NAME ${key})
    parse_object(${object})
endmacro()

# Get a package's effective URL, for an already parsed object
function(get_package_url_object out)
    if (${url})
        set(${out} "${url}")
    else()
        get_package_url(URL_OUT "${out}"
            GIT_HOST "${git_host}"
            REPO "${repo}"
            VERSION "${version}"
            ARTIFACT "${artifact}"
            PACKAGE "${package}")
    endif()

    return(PROPAGATE ${out})
endfunction()

# Fetch a package from an already-parsed object.
function(fetch_package_object)
    set(optionArgs FORCE)
    cmake_parse_arguments(ARG "${optionArgs}" "" "" ${ARGN})

    if (${url})
        set(pkg_url "${url}")
    else()
        get_package_url(URL_OUT pkg_url
            GIT_HOST "${git_host}"
            REPO "${repo}"
            VERSION "${version}"
            ARTIFACT "${artifact}"
            PACKAGE "${package}")
    endif()

    get_cache_path(${package} ${version} cache_path)

    set(_fetch_args
        URL "${pkg_url}"
        HASH "${hash}"
        PATH "${cache_path}"
        PATCHES ${patches})

    if(ARG_FORCE)
        list(APPEND _fetch_args FORCE)
    endif()

    fetch_package(${_fetch_args})
endfunction()

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
                fatal("Fatal: could not find one of jq, Python, or perl"
                    "(json_pp). Install one of these packages to use"
                    "CPMUtil's tooling. If they ARE installed, your"
                    "CMake installation is broken.")
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

# Computes expected SHA512 hash of a package
# Requires already-parsed object
function(get_package_hash url out)
    mktempdir(TMP)

    get_filename_component(filename ${url} NAME)
    set(file ${TMP}/${filename})

    cpm_download("${url}" "${file}")
    file(SHA512 ${file} ${out})
    return(PROPAGATE ${out})
endfunction()

# Update hash and version of a package
# Outputs the updated object
function(modify_package object version hash out)
    string(JSON new_object SET "${object}" hash "\"${hash}\"")
    string(JSON new_object SET "${new_object}" version "\"${version}\"")

    set(${out} "${new_object}")
    return(PROPAGATE ${out})
endfunction()

function(get_cpmfile_keys out)
    get_cpmfile_content(object)

    string(JSON len LENGTH ${object})

    math(EXPR last_index "${len} - 1")
    foreach(i RANGE ${last_index})
        string(JSON key MEMBER ${object} ${i})
        list(APPEND ${out} ${key})
    endforeach()

    return(PROPAGATE ${out})
endfunction()

# Parse positional arguments from the command line
# Supports -h/--help to call usage() and -a/--all to expand to all package keys.
# Callers can set NO_ALL before calling to disable -a expansion.
# Callers can set NO_CI before calling to exclude CI packages when expanding -a.
function(parse_script_args out)
    if(NOT CMAKE_SCRIPT_MODE_FILE OR NOT CMAKE_ARGC)
        set(${out} "" PARENT_SCOPE)
        return()
    endif()

    set(found_script FALSE)
    set(idx 0)
    set(all_flag FALSE)

    get_filename_component(script_name "${CMAKE_SCRIPT_MODE_FILE}" NAME)

    while(idx LESS CMAKE_ARGC)
        if(found_script)
            set(arg "${CMAKE_ARGV${idx}}")
            if(arg STREQUAL "-h" OR arg STREQUAL "--help")
                usage()
                cmake_language(EXIT 0)
            elseif(arg STREQUAL "-a" OR arg STREQUAL "--all")
                set(all_flag TRUE)
            elseif(NOT arg STREQUAL "--")
                list(APPEND positional_args ${arg})
            endif()
        elseif(CMAKE_ARGV${idx} STREQUAL CMAKE_SCRIPT_MODE_FILE)
            set(found_script TRUE)
        else()
            get_filename_component(arg_name "${CMAKE_ARGV${idx}}" NAME)
            if(arg_name STREQUAL script_name)
                set(found_script TRUE)
            endif()
        endif()
        math(EXPR idx "${idx} + 1")
    endwhile()

    if(all_flag AND NOT NO_ALL)
        get_cpmfile_keys(all_keys)
        if(NO_CI)
            set(filtered_keys)
            foreach(key ${all_keys})
                parse_key(${key})
                if(NOT ci)
                    list(APPEND filtered_keys ${key})
                endif()
            endforeach()
            set(positional_args ${filtered_keys})
        else()
            set(positional_args ${all_keys})
        endif()
    endif()

    set(${out} ${positional_args} PARENT_SCOPE)
endfunction()