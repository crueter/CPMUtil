# CPMUtil

CPMUtil is a high-performance wrapper around [CMake Package Manager](https://github.com/cpm-cmake/CPM.cmake). It aims to reduce boilerplate, add useful utility functions and tooling to make dependency management a piece of cake.

## Abstract

The "traditional" method of dependency management is to use `find_package`, and if unavailable, include dependencies with vcpkg or Git submodules. However, this approach has a number of significant problems:
- Both are very slow
- Submodules are difficult to archive
- vcpkg is a dependency itself!
- Lots of manual intervention and target checking needed

The goal of CPM.cmake was to solve these problems and integrate dependency checking within CMake. CPMUtil aims to iterate upon CPM's base and make dependency management a truly and completely solved problem. CPMUtil adds:
- Full shell script tooling for dependency management and sanity checking
- Definitions in JSON to aggregate dependencies in one place (no need to write CMake just to change some deps around)
- Utility functions that handle all sorts of boilerplate for you
- Defaults and enforcements that you will literally always want

## Specifics

For usage, see the [documentation](./docs/CPMUtil.md).

## Tooling

See the [tooling docs](./tools/cpm)

## Usage in Projects

You are recommended to copy:

- `CPM.cmake`
- `CPMUtil.cmake`
- `tools`
- `docs/CPMUtil.md`

To your project.

### Changes

CPMUtil itself is designed to be relatively *plug-and-play*, but the tooling may need changes depending on your specific setup. You will almost certainly need to modify:

- `tools/cpm/common.sh`
- `tools/cpm/check-updates.sh`

See the scripts for more information.