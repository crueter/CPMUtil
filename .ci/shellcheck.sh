#!/bin/sh -e

# SPDX-FileCopyrightText: Copyright 2025 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

find tools .ci -name "*.sh" -exec shellcheck -s sh -S style {} \;
