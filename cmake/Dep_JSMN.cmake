include_guard(GLOBAL)
include("${PROJECT_SOURCE_DIR}/cmake/Dependencies.cmake")

dep_declare_fetchcontent(
    jsmn
    GIT_REPOSITORY https://github.com/zserge/jsmn.git
    GIT_TAG v1.1.0
)

FetchContent_MakeAvailable(jsmn)

if(NOT TARGET jsmn)
    add_library(jsmn INTERFACE)
    target_include_directories(jsmn INTERFACE "${jsmn_SOURCE_DIR}")
endif()
