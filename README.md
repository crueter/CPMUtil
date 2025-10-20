# CPMUtil

CPMUtil is a high-performance wrapper around [CMake Package Manager](https://github.com/cpm-cmake/CPM.cmake). It aims to reduce boilerplate and add useful utility functions and tooling to make dependency management a piece of cake.

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

For usage, see the [documentation](./docs/CPMUtil/).

## Tooling

See the [tooling docs](./tools/cpm).

## Hosts

Currently, CPMUtil only supports GitHub, Gitea, and Forgejo. GitLab is not supported and probably won't ever be.

## Usage in Projects

You are recommended to copy:

- `CPM.cmake`
- `CPMUtil.cmake`
- `tools`
- `docs/CPMUtil.md`

To your project.

[Releases](https://git.crueter.xyz/CMake/CPMUtil/releases) are created periodically. These include docs, tools, and the modules themselves, packaged in `docs`, `tools`, and `CMakeModules` subdirectories respectively.

### Licensing

CPMUtil follows the [GPLv3](./LICENSE). The definition of the GPL within the realm of scripts/CMake modules is a bit iffy, but it can best be defined that every project that uses CPMUtil *or* its tooling MUST be licensed under a form of GPL.

* Remember: the point of the GPL is *specifically* to prevent corporations from taking open-source code and using it in their [proprietary junk](https://www.cs.vu.nl/~ast/intel/). Adding this to your permissively-licensed project *defeats the entire purpose* of the GPL!
* If you don't like it, don't use it, or better yet, switch to the GPL.
  - Or make your own... provided you DON'T look at CPMUtil's code!

### Changes

CPMUtil itself is designed to be relatively *plug-and-play*, but the tooling may need changes depending on your specific setup. You will almost certainly need to modify:

- `tools/cpm/common.sh`
- `tools/cpm/check-updates.sh`

See the scripts for more information.
