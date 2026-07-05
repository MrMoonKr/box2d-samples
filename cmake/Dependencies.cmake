include_guard(GLOBAL)

include(FetchContent)

function(dep_resolve_paths name out_source_dir out_binary_dir)
    string(TOLOWER "${name}" dep_name)
    set(${out_source_dir} "${PROJECT_SOURCE_DIR}/deps/${dep_name}-src" PARENT_SCOPE)
    set(${out_binary_dir} "${CMAKE_BINARY_DIR}/_deps/${dep_name}-build" PARENT_SCOPE)
endfunction()

function(dep_declare_fetchcontent name)
    set(options)
    set(one_value_args GIT_REPOSITORY GIT_TAG)
    cmake_parse_arguments(DEP "${options}" "${one_value_args}" "" ${ARGN})

    if(NOT DEP_GIT_REPOSITORY OR NOT DEP_GIT_TAG)
        message(FATAL_ERROR "dep_declare_fetchcontent(${name}) requires GIT_REPOSITORY and GIT_TAG")
    endif()

    dep_resolve_paths("${name}" dep_source_dir dep_binary_dir)

    FetchContent_Declare(
        "${name}"
        GIT_REPOSITORY "${DEP_GIT_REPOSITORY}"
        GIT_TAG "${DEP_GIT_TAG}"
        GIT_SHALLOW TRUE
        GIT_PROGRESS TRUE
        SOURCE_DIR "${dep_source_dir}"
        BINARY_DIR "${dep_binary_dir}"
    )
endfunction()
