# `FetchBoostContent_Declare`

## Boost modules

`FetchBoostContent_Declare` is the Boost analogous of [FetchContent_Declare]. The function also accepts the same arguments as [FetchContent_Declare].

{{ code_snippet("CMakeLists.txt", "declare") }}

!!! note

    The module name always needs to start with `"boost_"`

The declare function stores details about the Boost module and calls the regular [FetchContent_Declare] function for the module. These properties need to be later retrieved by other functions. The implementation ensures only the first declaration is used when populating the library.

Note that `FetchContent` is often used in conjunction with [find_package], where the library is declared and fetched only when not available in the system:

{{ code_snippet("CMakeLists.txt", "find_package_or_declare") }}

--8<-- "docs/references.md"
