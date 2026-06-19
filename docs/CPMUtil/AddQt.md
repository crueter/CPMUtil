# AddQt

Simply call `AddQt(<Qt Version> <Qt Repository>)` before any Qt `find_package` calls and everything will be set up for you. On Linux, the bundled Qt library is built as a shared library, and provided you have OpenSSL and X11, everything should just work.

On Windows, MinGW, and MacOS, Qt is bundled as a static library. No further action is needed, as the provided libraries automatically integrate the Windows/Cocoa plugins, alongside the corresponding Multimedia and Network plugins.

## Example

See an example in the [`tests/qt`](https://git.crueter.xyz/CMake/CPMUtil/src/branch/master/tests/qt/CMakeLists.txt) directory.

## Repositories

Generally, you should tailor Qt builds to your particular application. See [`crueter-ci/Qt`](https://github.com/crueter-ci/Qt) for examples
