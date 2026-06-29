#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

include(./ScriptUtils.cmake)

parse_script_args(args)

foreach(key ${args})
    parse_key(${key})

    get_package_url_object(pkg_url)
    echo("${key}: ${pkg_url}")
endforeach()