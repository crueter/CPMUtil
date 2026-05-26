# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

AddQt(QDash-CI/Qt 6.11.1)
find_package(Qt6 REQUIRED COMPONENTS Widgets MultimediaWidgets Network)

message(STATUS "Qt directory: ${Qt6_DIR}")

add_executable(test_qt main.cpp)
target_link_libraries(test_qt Qt6::Widgets Qt6::MultimediaWidgets Qt6::Network)