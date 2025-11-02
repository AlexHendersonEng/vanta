# Set minimum CMake version
cmake_minimum_required (VERSION 3.20)

# Check platform
if(NOT WIN32 AND NOT UNIX)
    message(FATAL_ERROR "Platform not supported!")
endif()

# Options
option(BUILD_DOCS "Build documentation with Doxygen" NO)
option(BUILD_TESTS "Build tests" NO)

# Variables
set(THIRD_PARTY_DIR "${CMAKE_SOURCE_DIR}/../third-party")
set(VCPKG_DIR "${THIRD_PARTY_DIR}/vcpkg")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Includes
include("cmake/utils.cmake")

# Enable Hot Reload for MSVC compilers if supported.
if(POLICY CMP0141)
    cmake_policy(SET CMP0141 NEW)
    set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>")
endif()

# Bootstrap vcpkg if required
if(WIN32)
    set(VCPKG_EXE "${VCPKG_DIR}/vcpkg.exe")
    set(BOOTSTRAP_CMD "${VCPKG_DIR}/bootstrap-vcpkg.bat")
else()
    set(VCPKG_EXE "${VCPKG_DIR}/vcpkg")
    set(BOOTSTRAP_CMD "${VCPKG_DIR}/bootstrap-vcpkg.sh")
endif()

if(NOT EXISTS "${VCPKG_EXE}")
    message(STATUS "Bootstrapping vcpkg...")
    execute_process(
        COMMAND "${BOOTSTRAP_CMD}"
        WORKING_DIRECTORY "${VCPKG_DIR}"
    )
endif()

# Add vcpkg as CMake toolchain file
if(EXISTS "${VCPKG_DIR}/scripts/buildsystems/vcpkg.cmake")
    set(CMAKE_TOOLCHAIN_FILE "${VCPKG_DIR}/scripts/buildsystems/vcpkg.cmake")
endif()

# Project
project(
    "vanta"
    VERSION 0.1.0
    LANGUAGES CXX
)

# Include sub-projects.
if(NOT BUILD_DOCS)
    add_subdirectory("src")
    add_subdirectory("apps")
    if(BUILD_TESTS)
        enable_testing()
        add_subdirectory("tests")
    endif()
else()
    # Define variables
    set(DOXYGEN_VERSION 1.14.0)
    set(DOXYGEN_DIR "${THIRD_PARTY_DIR}/doxygen")
    set(DOCS_DIR "${CMAKE_SOURCE_DIR}/docs")
    set(DOCS_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/docs")

    # Define platform specific Doxygen variables
    if(WIN32)
        set(DOXYGEN_ARCHIVE "doxygen-${DOXYGEN_VERSION}.windows.x64.bin.zip")
        set(DOXYGEN_URL "https://www.doxygen.nl/files/${DOXYGEN_ARCHIVE}")
        set(DOXYGEN_EXECUTABLE "doxygen.exe")
    else()
        set(DOXYGEN_ARCHIVE "doxygen-${DOXYGEN_VERSION}.linux.bin.tar.gz")
        set(DOXYGEN_URL "https://www.doxygen.nl/files/doxygen-${DOXYGEN_VERSION}.linux.bin.tar.gz")
        set(DOXYGEN_EXECUTABLE "doxygen")
    endif()

    # Create Doxygen directory if required
    if(NOT EXISTS "${DOXYGEN_DIR}")
        message(STATUS "Doxygen directory not found. Creating '${DOXYGEN_DIR}'.")
        file(MAKE_DIRECTORY "${DOXYGEN_DIR}")
    endif()

    # Download and extract Doxygen if required
    if(NOT EXISTS "${DOXYGEN_DIR}/${DOXYGEN_EXECUTABLE}")
        file(WRITE "${DOXYGEN_DIR}/.gitignore" "*")

        message(STATUS "Doxygen executable not found. Downloading doxygen from '${DOXYGEN_URL}' to '${DOXYGEN_DIR}/${DOXYGEN_ARCHIVE}'.")
        file(DOWNLOAD "${DOXYGEN_URL}" "${DOXYGEN_DIR}/${DOXYGEN_ARCHIVE}" SHOW_PROGRESS)

        message(STATUS "Extracting '${DOXYGEN_DIR}/${DOXYGEN_ARCHIVE}' to '${DOXYGEN_DIR}'.")
        file(ARCHIVE_EXTRACT INPUT "${DOXYGEN_DIR}/${DOXYGEN_ARCHIVE}" DESTINATION "${DOXYGEN_DIR}")

        file(REMOVE "${DOXYGEN_DIR}/${DOXYGEN_ARCHIVE}")
    endif()

    # Make docs directory in build directory
    file(MAKE_DIRECTORY "${DOCS_BUILD_DIR}")

    # Configure Doxyfile
    set(DOXYFILE_IN "Doxyfile.in")
    set(DOXYFILE_OUT "Doxyfile")
    configure_file("${DOCS_DIR}/${DOXYFILE_IN}" "${DOCS_BUILD_DIR}/${DOXYFILE_OUT}")

    # Add documentation target
    add_custom_target(
        docs
        COMMAND "${DOXYGEN_DIR}/${DOXYGEN_EXECUTABLE}" "${DOCS_BUILD_DIR}/${DOXYFILE_OUT}"
        WORKING_DIRECTORY "${DOCS_BUILD_DIR}"
        VERBATIM
    )

    # Documentation install
    install(DIRECTORY "${DOCS_BUILD_DIR}" DESTINATION /)
endif()

# Include CPack module
include(CPack)
