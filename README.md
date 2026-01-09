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

CPMUtil.cmake defines dependencies in a JSON file or via CMake. You must specify a repository in the form `owner/repo` alongside a commit sha, tag, or tag + artifact. CPMUtil will then take care of URL creation, hash verification, and more for you, with little to no boilerplate required. Packages can be added interactively via the `tools/cpmutil.sh` script, with `tools/cpmutil.sh package add`, and added into a project via `AddJsonPackage(package-name)`. The `cpmutil.sh` script also defines several other useful operations to make dependency management a breeze.

### Advantages over Submodules

- Submodules clone the entire git history of a subproject with no realistic way to avoid it. This is a huge problem for people with slow internet. CPMUtil instead works on significantly smaller source snapshots or artifacts, resulting in a massive improvement in total clone + configure time. This also means it takes up less overall space.
- CPMUtil automatically manages system dependencies for you. No need to manually run `find_package(package)` and then check if the target exists and add a subdirectory.
- Submodules are inherently not portable between commits. If a commit changes a submodule's revision and you forget to run `git submodule update`, you may be stuck with a dependency that is either far too new or far too old. With CPMUtil, each revision/version is stored separately, meaning you will never have to worry about weird submodule version conflicts.
- CPMUtil makes it incredibly trivial to change a package's version. Using the provided `cpmutil.sh` script, one command is all that's needed. With submodules, you have to cd into the submodule directory (which may be hard to find), throw out any potential changes you may have, and check out a different revision.
- Submodules require third-party software such as `git-archive-all` to archive and distribute source code with all of its dependencies. CPMUtil provides `cpmutil.sh package fetch -a`, which will cache everything into `.cache`, ready for distribution in an instant.

### Advantages over vcpkg

- vcpkg has limited support for systems other than Windows and Linux. CPMUtil works everywhere CMake does.
- vcpkg has analytics by default. CPMUtil doesn't.
- vcpkg is significantly slower than CPMUtil, especially with ccache. CPMUtil integrates directly into the build system, meaning you can cache everything with the help of {s,}ccache.
- CPMUtil is far more configurable. vcpkg enforces default options for each "recipe", whereas packages included via CPMUtil can be debloated and configured to your heart's content.
- vcpkg requires extra setup to integrate it into your repository, as *it's a dependency itself!* CPMUtil can be integrated fully with just a few small files.

## Docs

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

CPMUtil follows the [LGPLv3](./LICENSE). The definition of the GPL within the realm of scripts/CMake modules is a bit iffy, but it can best be defined that every project that uses CPMUtil *or* its tooling MUST be licensed under a form of GPL. Older versions of CPMUtil were licensed under the GPL and thus incompatible with LGPL, but now any project running the LGPL, GPL, or AGPL, versions 3 or later, are fully compatible with CPMUtil.

* Remember: the point of the GPL is *specifically* to prevent corporations from taking open-source code and using it in their [proprietary junk](https://www.cs.vu.nl/~ast/intel/). Adding this to your permissively-licensed project *defeats the entire purpose* of the GPL!
* If you don't like it, don't use it, or better yet, switch to the GPL.
  - Or make your own... provided you DON'T look at CPMUtil's code!

### Changes

CPMUtil itself is designed to be relatively *plug-and-play*, but the tooling may need changes depending on your specific setup. You will almost certainly need to modify `tools/cpm/common.sh`

See the scripts for more information.

### Notes

CPMUtil currently has a hard dependency on [`DetectArchitecture.cmake`](https://git.crueter.xyz/CMake/Modules/src/branch/master/DetectArchitecture.cmake) and [`DetectPlatform.cmake`](https://git.crueter.xyz/CMake/Modules/src/branch/master/DetectPlatform.cmake). This is unlikely to change any time soon.