include_guard(GLOBAL)
include("${PROJECT_SOURCE_DIR}/cmake/Dependencies.cmake")

dep_declare_fetchcontent(
    implot
    GIT_REPOSITORY https://github.com/epezent/implot.git
    GIT_TAG v0.17
)

FetchContent_MakeAvailable(implot)

if(NOT TARGET implot)
    add_library(implot STATIC
        "${implot_SOURCE_DIR}/implot.cpp"
        "${implot_SOURCE_DIR}/implot_items.cpp"
        "${implot_SOURCE_DIR}/implot_demo.cpp"
        "${implot_SOURCE_DIR}/implot.h"
        "${implot_SOURCE_DIR}/implot_internal.h"
    )

    target_include_directories(implot PUBLIC "${implot_SOURCE_DIR}")
    target_link_libraries(implot PUBLIC imgui)
    set_target_properties(implot PROPERTIES
        CXX_STANDARD 20
        CXX_STANDARD_REQUIRED YES
        CXX_EXTENSIONS NO
    )
endif()
