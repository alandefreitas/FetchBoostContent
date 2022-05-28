# Linking targets

The strategy to link libraries depend on how they have been fetched.

## Header-only libraries

Boost header-only libraries can be linked with the `Boost::headers` interface target:

{{ code_snippet("example/CMakeLists.txt", "link_header_only") }}

The advantage of the interface target `Boost::headers` is that `find_package(Boost)` also provides this target, so that the "find-or-fetch" pattern works transparently. 

{{ code_snippet("CMakeLists.txt", "find_package_or_declare") }}

This assumes the library was integrated with `FetchBoostContent_MakeAvailable` or the interface target was created manually with a pattern such as 

{{ code_snippet("CMakeLists.txt", "interface") }}

## Individual interface targets

Header-only modules also provide interface targets representing a single library in their build script. 

{{ code_snippet("example/CMakeLists.txt", "link_interface") }}

This assumes the library was integrated with `FetchBoostContent_MakeAvailable` or the module targets were created manually by including their subdirectories:

{{ code_snippet("CMakeLists.txt", "declare_and_make_available") }}
{{ code_snippet("CMakeLists.txt", "add_subdirs") }}

The advantage of these targets is that only include the directories required for a given target are associated with the executable.  

However, note that the integration script used by `find_package(Boost)` is not generated with the usual CMake facilities to export targets. Thus, not all targets available from module CMake build scripts are also provided with `find_package(Boost)`. 

In this case, we need special treatment for the case when `find_package(Boost)` has been used.

## Compiled libraries

Targets are provided for modules that require building and linking:

{{ code_snippet("example/CMakeLists.txt", "link_built") }}

This also assumes the library was integrated with `FetchBoostContent_MakeAvailable` or the module targets were created manually by including their subdirectories. Otherwise, a customized script should be provided to build these modules.

The advantage of targets such as `Boost::<module>` is that `find_package(Boost COMPONENTS <modules>)` also provides this target, so that the "find-or-fetch" pattern works transparently.

## Summary

When fetching libraries, we usually want to build the libraries as if `find_package(Boost)` was being used. This allows us to use the targets in such a way that they can be linked transparently, without special treatment for each of the integration methods. 

In practice, this means we should generate the `Boost::headers` and `Boost::<module>` targets. `Boost::headers` includes all libraries and `Boost::<module>` represent individual compiled libraries.

To achieve this, we can usually import the libraries with the following relationship between the strategies presented above:

1. Use `find_package` with the required `COMPONENTS` when possible. Importing a Boost installation is faster than fetching and building all modules.
2. Use `FetchBoostContent_MakeAvailable` when possible. This creates compatible targets for header-only (`Boost::headers`) and compiled libraries (`Boost::<module>`).
3. Use `FetchBoostContent_MakeAvailable` for the library dependencies when possible so that not all libraries have to be included manually.
3. Add the library include directories to the `Boost::headers` target when creating targets manually.

--8<-- "docs/references.md"
