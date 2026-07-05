include_guard(GLOBAL)
include("${PROJECT_SOURCE_DIR}/cmake/Dependencies.cmake")

set(NFD_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(NFD_INSTALL OFF CACHE BOOL "" FORCE)

dep_declare_fetchcontent(
    nfd
    GIT_REPOSITORY https://github.com/btzy/nativefiledialog-extended.git
    GIT_TAG v1.3.0
)

FetchContent_MakeAvailable(nfd)
