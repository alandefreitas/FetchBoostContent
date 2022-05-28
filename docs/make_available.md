# `FetchBoostContent_MakeAvailable`

## Fetching modules

`FetchBoostContent_MakeAvailable` is the Boost analogous of [FetchContent_MakeAvailable]. The function can be used to simplify the pattern to create library targets into only 2 steps:

{{ code_snippet("CMakeLists.txt", "declare_and_make_available") }}

`FetchBoostContent_MakeAvailable` will include the library with a procedure similar to common pattern of adding subdirectories. Thus, it is roughly equivalent to:

{{ code_snippet("CMakeLists.txt", "make_available_pattern") }}

Note how `FetchBoostContent_MakeAvailable` cannot be replaced with [FetchContent_MakeAvailable], which will only add the main module. 

`FetchBoostContent_MakeAvailable` is recommendable over the pattern above because it also takes care of a few details might go wrong in the pattern above, such as:

- Not including subdirectories that have already been included with `FetchBoostContent_MakeAvailable` 
- Not including subdirectories for modules whose targets have already been defined
- Not including subdirectories for modules without a `CMakeLists.txt` file
- Adding the `include` module subdirectory to the `Boost::headers` target even if a `CMakeLists.txt` file isn't available
- Create the `Boost::headers` target if one doesn't exist yet
- Adding the `include` directories to the `Boost::headers` target only if it's not an imported target

This is especially important when more than one Boost module will be included in the same project, as they will depend on a dependency intersection of modules that will attempt to add the same subdirectory twice. 

As with `FetchBoostContent_Populate`, this pattern assumes the libraries can be integrated with [add_subdirectory] or are header-only. A special pattern might be required for a dependency that doesn't meet this criteria.

--8<-- "docs/references.md"
