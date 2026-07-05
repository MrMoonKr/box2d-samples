include_guard(GLOBAL)
include("${PROJECT_SOURCE_DIR}/cmake/Dependencies.cmake")

set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(BOX2D_SAMPLES OFF CACHE BOOL "" FORCE)
set(BOX2D_BENCHMARKS OFF CACHE BOOL "" FORCE)
set(BOX2D_DOCS OFF CACHE BOOL "" FORCE)
set(BOX2D_UNIT_TESTS OFF CACHE BOOL "" FORCE)
set(BOX2D_PROFILE OFF CACHE BOOL "" FORCE)

dep_declare_fetchcontent(
    box2d
    GIT_REPOSITORY https://github.com/MrMoonKr/box2d.git
    GIT_TAG 0fd80293d3251fb6ef7a27340be8767b9a216179
)

FetchContent_MakeAvailable(box2d)
