include_guard(GLOBAL)
include("${PROJECT_SOURCE_DIR}/cmake/Dependencies.cmake")

dep_declare_fetchcontent(
    glad
    GIT_REPOSITORY https://github.com/Dav1dde/glad.git
    GIT_TAG v2.0.8
)

FetchContent_MakeAvailable(glad)

set(GLAD_SOURCES_DIR "${glad_SOURCE_DIR}")
include("${glad_SOURCE_DIR}/cmake/GladConfig.cmake")

if(NOT TARGET glad)
    glad_add_library(glad REPRODUCIBLE LOADER API gl:core=3.3)
endif()
