# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

# CPM.cmake - CMake's missing package manager
# ===========================================
# See https://github.com/cpm-cmake/CPM.cmake for usage and update instructions.
#
# MIT License
# -----------
#[[
  Copyright (c) 2019-2023 Lars Melchior and contributors

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
]]

include_guard(GLOBAL)

set(CPM_PACKAGES "" CACHE INTERNAL "")

include(FetchContent)

# Create a custom FindXXX.cmake module for a CPM package.
# This prevents `find_package(NAME)` from finding the system library
# This is a noop in script mode
function(cpm_create_module_file Name)
    if(DEFINED CMAKE_FIND_PACKAGE_REDIRECTS_DIR)
        # https://cmake.org/cmake/help/latest/module/FetchContent.html
        string(TOLOWER ${Name} NameLower)

        file(WRITE ${CMAKE_FIND_PACKAGE_REDIRECTS_DIR}/${NameLower}-config.cmake
            "include(\"\${CMAKE_CURRENT_LIST_DIR}/${NameLower}-extra.cmake\" \
        OPTIONAL)\n"
            "include(\"\${CMAKE_CURRENT_LIST_DIR}/${Name}Extra.cmake\" OPTIONAL)\n")

        file(WRITE ${CMAKE_FIND_PACKAGE_REDIRECTS_DIR}/${NameLower}-config-version.cmake
            "set(PACKAGE_VERSION_COMPATIBLE TRUE)\n"
            "set(PACKAGE_VERSION_EXACT TRUE)\n")
    endif()
endfunction()

# main logic
function(cpm_util_internal_add_package)
    set(oneValueArgs
        NAME
        FORCE
        VERSION
        DOWNLOAD_ONLY
        SOURCE_DIR
        EXCLUDE_FROM_ALL
        SOURCE_SUBDIR
    )

    set(multiValueArgs OPTIONS)

    cmake_parse_arguments(
        CPM_ARGS
        ""
        "${oneValueArgs}"
        "${multiValueArgs}"
        "${ARGN}")

    if(NOT DEFINED CPM_ARGS_SOURCE_DIR)
        message(FATAL_ERROR "[CPMUtil] InternalAddPackage: SOURCE_DIR is required")
    endif()

    if(CPM_ARGS_DOWNLOAD_ONLY)
        set(DOWNLOAD_ONLY ${CPM_ARGS_DOWNLOAD_ONLY})
    else()
        # Default to DOWNLOAD_ONLY in script mode.
        set(DOWNLOAD_ONLY ${CMAKE_SCRIPT_MODE_FILE})
    endif()

    if(NOT DEFINED CPM_ARGS_NAME)
        message(FATAL_ERROR "[CPMUtil] InternalAddPackage: NAME is required")
    endif()

    if(NOT DEFINED CPM_ARGS_VERSION)
        message(FATAL_ERROR "[CPMUtil] InternalAddPackage: VERSION is required")
    endif()

    # check if package already added
    if("${CPM_ARGS_NAME}" IN_LIST CPM_PACKAGES)
        # TODO: use cpmutil machinery instead
        set(package_ver ${CPM_PACKAGE_${CPM_ARGS_NAME}_VERSION})

        # check if newer ver is already requested
        if("${package_ver}" VERSION_LESS "${CPM_ARGS_VERSION}")
        message(WARNING
            "[CPMUtil] Requires a newer version of ${CPM_ARGS_NAME} "
            "(${CPM_ARGS_VERSION}) than currently included "
            "(${package_ver}).")
        endif()

        cpm_get_fetch_properties(${CPM_ARGS_NAME})
        set(${CPM_ARGS_NAME}_ADDED NO)
        cpm_export_variables(${CPM_ARGS_NAME})
        return()
    endif()

    cpmregisterpackage("${CPM_ARGS_NAME}" "${CPM_ARGS_VERSION}")

    if(DEFINED FETCHCONTENT_BASE_DIR)
        set(CPM_FETCHCONTENT_BASE_DIR ${FETCHCONTENT_BASE_DIR})
    else()
        set(CPM_FETCHCONTENT_BASE_DIR ${CMAKE_BINARY_DIR}/_deps)
    endif()

    # Subbuild, etc
    string(TOLOWER ${CPM_ARGS_NAME} lower_case_name)

    set(fetch_source_dir ${CPM_ARGS_SOURCE_DIR})
    if(NOT IS_ABSOLUTE ${CPM_ARGS_SOURCE_DIR})
        get_filename_component(
            fetch_source_dir
            ${CPM_ARGS_SOURCE_DIR}
            REALPATH
            BASE_DIR ${CMAKE_CURRENT_BINARY_DIR}
        )
    endif()

    # FetchContent args
    set(fetchContentDeclareExtraArgs SYSTEM)
    if(${CPM_ARGS_EXCLUDE_FROM_ALL})
        list(APPEND fetchContentDeclareExtraArgs EXCLUDE_FROM_ALL)
    endif()

    if(DEFINED CPM_ARGS_SOURCE_SUBDIR)
        list(APPEND fetchContentDeclareExtraArgs
            SOURCE_SUBDIR ${CPM_ARGS_SOURCE_SUBDIR})
    endif()

    if(CPM_ARGS_OPTIONS AND NOT DOWNLOAD_ONLY)
        foreach(OPTION ${CPM_ARGS_OPTIONS})
            cpm_parse_option("${OPTION}")
            set(${OPTION_KEY} "${OPTION_VALUE}")
        endforeach()
    endif()

    if(NOT DOWNLOAD_ONLY)
        cpm_create_module_file(${CPM_ARGS_NAME})
    endif()

    FetchContent_Declare(
        ${CPM_ARGS_NAME}
        ${fetchContentDeclareExtraArgs}
        SOURCE_DIR ${fetch_source_dir})

    if(DOWNLOAD_ONLY)
        FetchContent_Populate(
            ${CPM_ARGS_NAME}
            ${fetchContentDeclareExtraArgs}
            SOURCE_DIR "${fetch_source_dir}"
            BINARY_DIR "${CPM_FETCHCONTENT_BASE_DIR}/${lower_case_name}-build"
            SUBBUILD_DIR "${CPM_FETCHCONTENT_BASE_DIR}/${lower_case_name}-subbuild")
    else()
        FetchContent_MakeAvailable(${CPM_ARGS_NAME})
    endif()

    set(CPM_PACKAGE_${CPM_ARGS_NAME}_SOURCE_DIR "${${lower_case_name}_SOURCE_DIR}" CACHE INTERNAL "")
    set(CPM_PACKAGE_${CPM_ARGS_NAME}_BINARY_DIR "${${lower_case_name}_BINARY_DIR}" CACHE INTERNAL "")

    cpm_get_fetch_properties("${CPM_ARGS_NAME}")

    set(${CPM_ARGS_NAME}_ADDED YES)
    cpm_export_variables("${CPM_ARGS_NAME}")
endfunction()

# export src, binary, and added vars to caller
macro(cpm_export_variables name)
    Propagate(${name}_SOURCE_DIR)
    Propagate(${name}_BINARY_DIR)
    Propagate(${name}_ADDED)
endmacro()

# registers a package that has been added to CPM
# TODO: Merge with CPMutil's machinery
function(CPMRegisterPackage PACKAGE VERSION)
    list(APPEND CPM_PACKAGES ${PACKAGE})
    set(CPM_PACKAGES ${CPM_PACKAGES} CACHE INTERNAL "")
    set("CPM_PACKAGE_${PACKAGE}_VERSION" ${VERSION}CACHE INTERNAL "")
endfunction()

function(cpm_get_fetch_properties PACKAGE)
    set(${PACKAGE}_SOURCE_DIR
        "${CPM_PACKAGE_${PACKAGE}_SOURCE_DIR}"
        PARENT_SCOPE)

    set(${PACKAGE}_BINARY_DIR
        "${CPM_PACKAGE_${PACKAGE}_BINARY_DIR}"
        PARENT_SCOPE)
endfunction()

# splits a package option
function(cpm_parse_option OPTION)
    string(REGEX MATCH "^[^ ]+" OPTION_KEY "${OPTION}")
    string(LENGTH "${OPTION}" OPTION_LENGTH)
    string(LENGTH "${OPTION_KEY}" OPTION_KEY_LENGTH)

    if(OPTION_KEY_LENGTH STREQUAL OPTION_LENGTH)
        # no value for key provided, assume user wants to set option to "ON"
        set(OPTION_VALUE "ON")
    else()
        math(EXPR OPTION_KEY_LENGTH "${OPTION_KEY_LENGTH}+1")
        string(SUBSTRING "${OPTION}" "${OPTION_KEY_LENGTH}" "-1" OPTION_VALUE)
    endif()

    set(OPTION_KEY "${OPTION_KEY}" PARENT_SCOPE)
    set(OPTION_VALUE "${OPTION_VALUE}" PARENT_SCOPE)
endfunction()
