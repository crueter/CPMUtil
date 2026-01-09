# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

include(CheckSymbolExists)
function(detect_architecture symbol arch)
    # The output variable needs to be unset between invocations otherwise
    # CMake's crazy scope rules will keep it defined
    unset(SYMBOL_EXISTS CACHE)

    if (NOT DEFINED ARCHITECTURE)
        set(CMAKE_REQUIRED_QUIET 1)
        check_symbol_exists("${symbol}" "" SYMBOL_EXISTS)
        unset(CMAKE_REQUIRED_QUIET)

        if (SYMBOL_EXISTS)
            set(ARCHITECTURE "${arch}" PARENT_SCOPE)
            set(ARCHITECTURE_${arch} 1 PARENT_SCOPE)
            add_definitions(-DARCHITECTURE_${arch}=1)
        endif()
    endif()
endfunction()

function(detect_architecture_symbols)
    if (DEFINED ARCHITECTURE)
        return()
    endif()

    set(oneValueArgs ARCH)
    set(multiValueArgs SYMBOLS)

    cmake_parse_arguments(ARGS "" "${oneValueArgs}" "${multiValueArgs}"
        "${ARGN}")

    set(arch "${ARGS_ARCH}")
    foreach(symbol ${ARGS_SYMBOLS})
        detect_architecture("${symbol}" "${arch}")

        if (ARCHITECTURE_${arch})
            message(DEBUG "[DetectArchitecture] Found architecture symbol ${symbol} for ${arch}")
            set(ARCHITECTURE "${arch}" PARENT_SCOPE)
            set(ARCHITECTURE_${arch} 1 PARENT_SCOPE)
            add_definitions(-DARCHITECTURE_${arch}=1)

            return()
        endif()
    endforeach()
endfunction()

detect_architecture_symbols(
    ARCH arm64
    SYMBOLS
        "__ARM64__"
        "__aarch64__"
        "_M_ARM64")

detect_architecture_symbols(
    ARCH x86_64
    SYMBOLS
        "__x86_64"
        "__x86_64__"
        "__amd64"
        "_M_X64"
        "_M_AMD64")

message(STATUS "[DetectArchitecture] Target architecture: ${ARCHITECTURE}")