# Variables
set(TARGET_NAME "hello_triangle")
set(SHADER_DIR ${CMAKE_CURRENT_SOURCE_DIR}/shaders)
set(SPIRV_DIR ${CMAKE_CURRENT_BINARY_DIR}/shaders)
set(COMPILED_SHADERS "")

# Get required packages
find_package(glfw3 REQUIRED)
find_package(glm CONFIG REQUIRED)
find_package(Vulkan REQUIRED)

# Add executable
add_executable("${TARGET_NAME}" "main.cpp")

# Link libraries
target_link_libraries("${TARGET_NAME}" PRIVATE glfw glm::glm Vulkan::Vulkan)

# Set C++ standard
set_property(TARGET "${TARGET_NAME}" PROPERTY CXX_STANDARD 20)

# Compile shaders
compile_shaders("${SHADER_DIR}" "${SPIRV_DIR}" "${TARGET_NAME}")
