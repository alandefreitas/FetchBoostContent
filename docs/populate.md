# `FetchBoostContent_Populate`

## Fetching modules

`FetchBoostContent_Populate` is the Boost analogous of [FetchContent_Populate]. The function also accepts the same arguments as [FetchContent_Populate].

{{ code_snippet("CMakeLists.txt", "populate") }}

The process usually starts with a call to `FetchBoostContent_GetProperties`. This first function is used to get properties about a module already declared with `FetchBoostContent_Declare`. In practice, this pattern is used to obtain `<module>_boost_beast_POPULATED` so we know whether this library has already been fetched. 

If the library has not been fetched yet (`NOT <library>_POPULATED`), we proceed with `FetchBoostContent_Populate` to finally fetch the library. This will initially invoke [FetchContent_Populate] for the main module and then fetch all of its dependencies.

## Procedure

At this point, the usual [FetchContent_Populate] would be done. For Boost libraries,we still need to identify, declare and populate dependencies.  `FetchBoostContent_Populate` achieves that with a logic similar to that of [Boost.Boostdep](https://www.boost.org/doc/libs/master/tools/boostdep/doc/html/):

- The library source and header files are scanned only for other internal boost dependencies.
- The dependencies are sorted by their level.
- Only the undeclared modules are declared and fetched as required
- Transitive dependencies are scanned recursively as required
- All dependencies are sorted by their transitive level

The libraries are only scanned the first time they are fetched. The dependency results are cached in the subdirectories for subsequent executions.

## Results

As [FetchContent_Populate], `FetchBoostContent_Populate` will set the variables `<library>_SOURCE_DIR` and `<library>_BINARY_DIR` on the parent scope. However, `FetchBoostContent_Populate` will also set: 

- `<library>_DEPS`: list of all transitive dependencies
- `<library>_SOURCE_DIRS`: source directory of all transitive dependencies
- `<library>_BINARY_DIRS`: binary directory of all transitive dependencies

## Creating targets

All of these results are sorted by their transitive dependency level in such a way that their subdirectories can be included in order.  

{{ code_snippet("CMakeLists.txt", "add_subdirs") }}

This pattern assumes all libraries can be integrated with [add_subdirectory], which is usually the case when the dependencies are included in order.  

## Header-only libraries

The `add_subdirectory` pattern might not work if some dependencies don't have a build script and have a script with bugs, such as attempting to link a target that is not a dependency, thus relying on a dependency that won't be fetched. This more likely to fail in a module at a high [dependency level](https://pdimov.github.io/boostdep-report/master/module-levels.html).

In these cases, especially when we only depend on header-only libraries, an easy solution is to create an `INTERFACE` target for all header files:

{{ code_snippet("CMakeLists.txt", "interface") }}

The name `Boost::headers` is used to make it compatible with the `IMPORTED` target created by [find_package]`(Boost)`.

## Boost Library Proposals

In general, Boost library proposals can be fetched with the same pattern as any other Boost library. `FetchBoostContent_Populate` will look for its dependencies as it would with any other Boost library.

However, fetching Boost library proposals with the "find-or-fetch" pattern might require a different logic, depending on how their scripts are defined. We have a number of potential problems here: 

- `find_package` might find Boost, in which case we don't need to fetch the Boost dependencies, but we still need to fetch the proposed library.
- `FetchBoostContent_Populate` will attempt to fetch dependencies, while `find_package` already found the modules we need.
- We cannot adjust `Boost::headers` with both dependencies, because it might be now an IMPORTED target.
- The proposed library assumes it's a subdirectory of the Boost super-project. The build script might not be ready to assume other dependencies could come from `find_package`.

This means we might need a different logic depending on whether Boost was found with `find_package`. For this reason, `FetchBoostContent_Populate` will _not_ fetch the module dependencies if `Boost_FOUND` is defined in the parent scope:

{{ code_snippet("CMakeLists.txt", "proposal_populate") }}

When Boost is found with `find_package` (`if (Boost_FOUND)`) we will have fetched the library without its dependencies and create a second interface target for the imported Boost headers and the library headers: 

{{ code_snippet("CMakeLists.txt", "proposal_when_found") }}

This second target can also be used to include any compilation step required by the library.

When Boost is not found with `find_package` (`if (Boost_FOUND)`) we fetch the library as usual with its dependencies.

{{ code_snippet("CMakeLists.txt", "proposal_when_not_found") }}

We can also create a convenience interface target for the Boost and library targets, which should now be all be defined in `Boost::headers`.

{{ code_snippet("CMakeLists.txt", "proposal_convenience_interface") }}

The convenience target allows us to reuse the same logic when linking to the library:

{{ code_snippet("example/CMakeLists.txt", "link_convenience_target") }}

This can be ignored if the library has a build script that handles integration as Boost sub_directories, as other projects' sub_directories, and as a standalone project.

--8<-- "docs/references.md"
