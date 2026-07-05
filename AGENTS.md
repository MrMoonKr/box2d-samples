# AGENTS.md

이 문서는 `box2d-samples` 프로젝트를 독립 실행형 샘플 앱으로 분리할 때 따라야 할 구조, CMake 규칙, 의존성 관리 방식, 구현 범위를 정의한다.

기준 스타일은 다음 문서를 따른다.

- `E:\M-Github-Graphics\OpenGL-Programming-Guide-9th\AGENTS.md`

이 프로젝트의 목적은 `E:\M-Github-DevOps\box2d\samples` 를 별도 저장소로 분리하고, 외부 의존성은 사용자가 선호하는 `FetchContent` 중심 구조로 재구성하는 것이다.

문서 인코딩은 UTF-8로 유지한다.

## 1. Goal

최종 목표:

- `box2d` 의 `samples` 앱을 독립 프로젝트로 분리
- 원본 샘플 소스는 현재 저장소의 `src/` 아래에 배치
- 원본 `shared` 유틸 소스도 현재 저장소 내부로 포함
- `glfw`, `glad`, `imgui`, `implot`, `nativefiledialog-extended` 등 외부 의존성은 `FetchContent` 기반으로 관리
- CMake 출력 경로와 디렉터리 구조는 기준 `AGENTS.md` 스타일을 따름
- Visual Studio 2022 x64 기준 `Debug` / `RelWithDebInfo` / `Release` preset 제공

## 2. Project Layout Rule

프로젝트는 아래 구조를 사용한다.

```text
project/
  .vscode/
  bin/
    Debug/
    RelWithDebInfo/
    Release/
  build/
    <preset-name>/
      _deps/
  cmake/
    Dependencies.cmake
    Dep_Box2D.cmake
    Dep_GLFW.cmake
    Dep_GLAD.cmake
    Dep_IMGUI.cmake
    Dep_IMPLOT.cmake
    Dep_NFD.cmake
    Dep_JSMN.cmake
  deps/
    <name>-src/
  libs/
    Debug/
    RelWithDebInfo/
    Release/
  src/
    data/
    shared/
    car.cpp
    car.h
    container.c
    container.h
    donut.cpp
    donut.h
    doohickey.cpp
    doohickey.h
    draw.c
    draw.h
    draw_text.cpp
    main.cpp
    sample.cpp
    sample.h
    sample_benchmark.cpp
    sample_bodies.cpp
    sample_character.cpp
    sample_collision.cpp
    sample_continuous.cpp
    sample_determinism.cpp
    sample_events.cpp
    sample_geometry.cpp
    sample_issues.cpp
    sample_joints.cpp
    sample_replay.cpp
    sample_robustness.cpp
    sample_shapes.cpp
    sample_stacking.cpp
    sample_world.cpp
    shader.c
    shader.h
    stb_image_write.h
  CMakeLists.txt
  CMakePresets.json
  AGENTS.md
  README.md
```

## 3. Source Migration Rule

원본 소스는 아래 기준으로 선별 복사한다.

- `E:\M-Github-DevOps\box2d\samples` 에서 `*.c`, `*.cpp`, `*.h` 파일만 `src/` 로 복사
- `E:\M-Github-DevOps\box2d\samples\data\*` -> `src/data/`
- `E:\M-Github-DevOps\box2d\shared\*` -> `src/shared/`

명시적 제외:

- `E:\M-Github-DevOps\box2d\samples\CMakeLists.txt`
- `E:\M-Github-DevOps\box2d\samples\data\` 디렉터리를 `src/` 루트로 통째 복사하는 방식

주의:

- 원본 `samples` 는 단독으로 빌드되지 않는다.
- `shared` 유틸 소스가 반드시 필요하다.
- `data/*.vs`, `data/*.fs` 는 런타임 파일로 두지 않고 CMake에서 임베드 헤더로 생성하는 방식을 우선 사용한다.
- upstream `samples/CMakeLists.txt` 는 `extern/glad`, `shared`, 원본 box2d target 구조에 묶여 있으므로 복사하지 않는다.

## 4. Dependency Strategy

의존성은 두 종류로 나눈다.

로컬 소스 포함:

- `samples` 본체 소스
- `shared` 유틸 소스
- `stb_image_write.h`

FetchContent 사용:

- `box2d`
- `glfw`
- `glad`
- `imgui`
- `implot`
- `nativefiledialog-extended`
- `jsmn`

## 5. FetchContent Rule

모든 외부 dependency는 `FetchContent` 기반으로 관리한다.

허용:

- `FetchContent_Declare`
- `FetchContent_MakeAvailable`

금지:

- `add_subdirectory()` 로 외부 저장소를 직접 vendor 방식으로 포함
- `ExternalProject`
- git submodule
- `third_party/`, `external/`, `vendor/` 디렉터리 생성
- 사전 빌드 바이너리 의존

## 6. Dependency Layout Rule

의존성 경로는 아래 규칙을 따른다.

```text
deps/<name>-src
build/<preset-name>/_deps/<name>-build
```

dependency 이름은 소문자 기준으로 통일한다.

예:

- `deps/glfw-src`
- `deps/imgui-src`
- `deps/box2d-src`

`FetchContent` 기본 경로를 그대로 사용하지 않는다.

- 각 dependency의 `SOURCE_DIR` 는 `${PROJECT_SOURCE_DIR}/deps/<name>-src` 로 고정
- 각 dependency의 `BINARY_DIR` 는 `${CMAKE_BINARY_DIR}/_deps/<name>-build` 로 고정

이 규칙을 helper가 강제하지 않으면 구현 오류로 간주한다.

## 7. Dependencies.cmake Rule

`cmake/Dependencies.cmake` 는 공통 helper만 둔다.

각 dependency는 반드시 개별 파일로 분리한다.

- `cmake/Dep_Box2D.cmake`
- `cmake/Dep_GLFW.cmake`
- `cmake/Dep_GLAD.cmake`
- `cmake/Dep_IMGUI.cmake`
- `cmake/Dep_IMPLOT.cmake`
- `cmake/Dep_NFD.cmake`
- `cmake/Dep_JSMN.cmake`

각 `Dep_*.cmake` 규칙:

- 한 파일에서 하나의 dependency만 정의
- repository URL, tag, target 생성 규칙은 해당 파일 내부에서만 결정
- root `CMakeLists.txt` 에서는 dependency 세부 URL / tag 를 다시 정의하지 않음
- 공통 helper는 `FetchContent_Declare(... SOURCE_DIR ... BINARY_DIR ...)` 로 경로 규칙을 강제
- helper는 dependency 이름을 받아 `${PROJECT_SOURCE_DIR}/deps/<name>-src` 와 `${CMAKE_BINARY_DIR}/_deps/<name>-build` 를 계산

버전 기준:

- 원본 `E:\M-Github-DevOps\box2d\samples\CMakeLists.txt` 가 이미 검증한 조합을 기본값으로 둔다
- 초기 기준 조합은 `glfw 3.4`, `imgui v1.92.7`, `implot v0.17`, `nfd v1.3.0`
- 최신 태그를 임의로 따라가지 않는다
- 특히 `imgui` 백엔드인 `imgui_impl_glfw.cpp`, `imgui_impl_opengl3.cpp` 는 API 호환성 영향을 받으므로 버전 고정을 우선한다

## 8. Box2D Rule

`box2d` 는 별도 dependency로 취급한다.

원칙:

- 현재 저장소 안에 `box2d` 소스를 복사하지 않는다
- `FetchContent` 로 upstream 저장소를 가져온다
- 샘플 앱은 `box2d` target 또는 `box2d::box2d` target에 링크한다

초기 구현에서는 다음 옵션을 우선 사용한다.

- `BUILD_SHARED_LIBS OFF`
- `BOX2D_SAMPLES OFF`
- `BOX2D_BENCHMARKS OFF`
- `BOX2D_DOCS OFF`
- `BOX2D_UNIT_TESTS OFF`
- `BOX2D_PROFILE OFF`

이유:

- 현재 프로젝트가 독립 샘플 앱이므로 upstream sample/test/doc 빌드는 필요 없다
- 분리 초기에는 Tracy 프로파일링 의존성을 제거해 빌드 복잡도를 낮춘다

참고:

- upstream `box2d` root `CMakeLists.txt` 에서 일부 옵션은 `if(PROJECT_IS_TOP_LEVEL)` 내부에 있다
- 따라서 `FetchContent` 서브프로젝트로 포함할 때 일부 옵션 지정은 현재 기준으로 no-op 일 수 있다
- 그래도 upstream 구조가 바뀌는 경우를 대비해 방어적 설정으로 유지한다

버전 고정 원칙:

- `src/` 아래로 복사한 `samples` 와 `shared` 소스는 특정 시점의 box2d API에 맞춰 고정된 스냅샷이다
- `Dep_Box2D.cmake` 의 `GIT_TAG` 는 그 시점의 box2d 버전 또는 커밋으로 고정한다
- box2d 태그를 임의로 최신화하지 않는다

## 9. GLAD Rule

`glad` 는 생성된 로더 소스를 포함한 정적 라이브러리 형태로 사용한다.

원칙:

- `Dav1dde/glad` 저장소를 `FetchContent` 로 가져온다
- `add_subdirectory()` 로 vendor 방식 포함은 하지 않는다
- `FetchContent_MakeAvailable(glad)` 이후 upstream의 `glad_add_library()` 를 사용해 configure 단계에서 로더를 생성한다
- GL 버전과 프로파일은 `Dep_GLAD.cmake` 에서 고정한다. 예: `gl:core=4.6`
- generated source와 build artifact는 `${CMAKE_BINARY_DIR}/_deps/<name>-build` 아래에 두고 `src/` 로 복사하지 않는다
- 프로젝트 내부에서는 `glad` static target만 사용하고 include 경로는 target 기반으로만 노출한다

빌드 전제:

- `glad_add_library()` 는 Python 코드 생성기를 실행하므로 빌드 머신에 Python 3가 설치되어 있어야 한다
- Python 3는 선택 옵션이 아니라 configure 성공을 위한 필수 전제다
- 이 전제는 `README.md` 와 실제 빌드 가이드에도 동일하게 명시한다

## 10. JSMN Rule

`jsmn` 은 header-only로 취급한다.

원칙:

- `FetchContent` 로 소스를 가져온다
- 프로젝트 내부에서 `jsmn` interface target을 만든다

## 11. IMGUI / IMPLOT Rule

`imgui`, `implot` 는 upstream 소스를 그대로 가져오되, 필요한 backend 소스를 현재 프로젝트에서 target으로 묶는다.

예상 backend:

- `imgui_impl_glfw.cpp`
- `imgui_impl_opengl3.cpp`

원칙:

- `imgui` static target 생성
- `implot` static target 생성
- `imgui` 는 `glfw`, `glad` 에 링크
- `implot` 는 `imgui` 에 링크

## 12. NFD Rule

Replay open dialog 용도로 `nativefiledialog-extended` 를 사용한다.

원칙:

- `FetchContent` 사용
- 테스트 및 설치 옵션은 비활성화
- upstream target 이름을 그대로 사용하되, 필요 시 alias target을 추가할 수 있다

## 13. Root CMake Rule

Root `CMakeLists.txt` 는 다음 순서를 따른다.

```text
1. cmake_minimum_required()
2. project()
3. 공통 변수 및 출력 디렉터리 설정
4. include(cmake/Dep_*.cmake)
5. shared library target 생성
6. samples executable target 생성
7. target_link_libraries()
8. shader embed header 생성
```

## 14. Output Rule

실행 파일 출력:

```text
bin/Debug
bin/RelWithDebInfo
bin/Release
```

정적 라이브러리 출력:

```text
libs/Debug
libs/RelWithDebInfo
libs/Release
```

사용할 CMake 변수:

- `CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG`
- `CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO`
- `CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE`
- `CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG`
- `CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO`
- `CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE`

## 15. Build Rule

멀티 설정 빌드를 우선 지원한다.

기본 대상:

- Visual Studio 17 2022
- x64

Preset 이름 규칙:

- configure: `vs2022-debug`, `vs2022-relwithdebinfo`, `vs2022-release`
- build: `build-debug`, `build-relwithdebinfo`, `build-release`

Windows 전용으로 `RelWithDebInfo` 구성을 공식 지원한다.

## 16. Compile Standard Rule

권장 표준:

- C 소스: C17
- C++ 소스: C++20

## 17. Include Rule

include path는 target 기반으로만 설정한다.

헤더 include 표기 규칙:

- 현재 프로젝트가 직접 소유한 로컬 헤더는 `"..."` 사용
- 외부 dependency 헤더는 `<...>` 사용

예:

- 로컬 헤더: `#include "draw.h"`, `#include "sample.h"`, `#include "utils.h"`
- 외부 헤더: `#include <box2d/box2d.h>`, `#include <glad/glad.h>`, `#include <GLFW/glfw3.h>`, `#include <imgui.h>`, `#include <implot.h>`, `#include <nfd.h>`, `#include <jsmn.h>`

원칙:

- `src/` 내부 파일끼리 참조하는 헤더는 `"..."` 로 유지
- `FetchContent` 및 target include path를 통해 들어오는 헤더는 `<...>` 로 통일
- 로컬 헤더와 외부 헤더의 소유권을 include 문법만 봐도 구분 가능해야 한다

허용:

```cmake
target_include_directories(...)
target_link_libraries(...)
```

금지:

```cmake
include_directories(...)
link_directories(...)
```

## 18. Shared Utility Rule

`src/shared` 는 별도 static library target으로 분리한다.

예상 소스:

- `benchmarks.c`
- `determinism.c`
- `human.c`
- `utils.c`

원칙:

- target 이름은 `shared` 로 유지 가능
- `shared` 의 public header가 `box2d/*.h` 타입을 노출하므로 `box2d` 는 `PUBLIC` 으로 링크한다
- include 경로는 `PUBLIC` 으로 노출한다
- `samples` 가 `box2d` 를 직접 링크하더라도 `shared` 의 usage requirement는 독립적으로 완전해야 한다

## 19. Samples Executable Rule

최종 실행 타깃은 `samples` 로 한다.

`samples` 는 아래에 링크한다.

- `box2d`
- `shared`
- `glfw`
- `glad`
- `imgui`
- `implot`
- `nfd`
- `jsmn`

필요 시 `box2d::box2d` 와 같은 alias target을 사용해도 된다.

`shared` 가 `box2d` 를 `PUBLIC` 으로 링크하더라도, `samples` 는 자체 소스에서 `box2d/*.h` 를 직접 include 하므로 `box2d` 를 직접 링크하는 구성을 기본으로 유지한다.

## 20. Shader Embed Rule

원본 `samples/data/*.vs`, `*.fs` 는 configure 단계에서 읽어 `shaders_embedded.h` 로 생성한다.

원칙:

- 생성 파일은 build directory에 둔다
- source directory의 `src/data` 를 기준으로 읽는다
- 런타임에 외부 shader 파일을 찾지 않도록 한다

## 21. VSCode Rule

`.vscode` 구성도 기준 스타일에 맞춘다.

필수 파일:

- `.vscode/launch.json`
- `.vscode/tasks.json`
- `.vscode/settings.json`

원칙:

- `cmake.useCMakePresets` 사용
- debugger는 Windows에서 `cppvsdbg`
- 실행 파일 경로는 기본적으로 `${workspaceFolder}/bin/Debug/samples.exe`
- `RelWithDebInfo` 디버깅이 필요하면 `${workspaceFolder}/bin/RelWithDebInfo/samples.exe` 구성도 추가한다
- `cwd` 는 `${workspaceFolder}`

## 22. Do Not Generate

생성 금지:

- `external/`
- `third_party/`
- `vendor/`
- `build/bin`
- `build/lib`

## 23. Initial Scope

초기 분리 작업 범위:

- CMake 골격 생성
- `Dep_*.cmake` 분리
- `src/` 로 원본 sample/shared/data 복사
- dependency target 연결
- `Debug` / `RelWithDebInfo` / `Release` preset 구성
- 최초 configure / build 검증

초기 범위에서 제외:

- Tracy 프로파일링 활성화
- Emscripten 지원
- Apple/Xcode 특화 설정
- upstream test/benchmark/doc 구성 복제

## 24. Verification Rule

dependency 구조 또는 출력 경로가 바뀌면 아래 순서로 검증한다.

```bash
cmake --preset vs2022-debug
cmake --build --preset build-debug
cmake --preset vs2022-relwithdebinfo
cmake --build --preset build-relwithdebinfo
cmake --preset vs2022-release
cmake --build --preset build-release
```

## 25. Agent Work Order

Agent 또는 작업자는 아래 순서를 따른다.

1. `AGENTS.md` 확인
2. 프로젝트 루트 구조 생성
3. `CMakePresets.json` 작성
4. `cmake/Dependencies.cmake` 및 `Dep_*.cmake` 작성
5. `src/` 아래에 sample/shared/data 복사
6. root `CMakeLists.txt` 작성
7. `Debug` / `RelWithDebInfo` / `Release` configure
8. `Debug` / `RelWithDebInfo` / `Release` build
9. `.vscode` 설정 보강

## 26. Decision Summary

이 프로젝트에서 핵심 결정은 다음과 같다.

- `samples` 와 `shared` 는 로컬 소스로 유지
- `box2d` 는 FetchContent dependency로 유지
- 외부 GUI / window / file dialog 의존성은 모두 target 기반으로 연결
- 기준 스타일 문서의 `bin/`, `build/`, `cmake/`, `deps/`, `libs/`, `src/` 구조를 그대로 따른다
