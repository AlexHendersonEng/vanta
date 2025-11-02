# Variables
set(TARGET_NAME "app1")

# Get required packages
find_package(glfw3 REQUIRED)
find_package(glm CONFIG REQUIRED)
find_package(Vulkan REQUIRED)

# Add executable
add_executable("${TARGET_NAME}" "app1.cpp")

# Link libraries
target_link_libraries("${TARGET_NAME}" PRIVATE glfw glm::glm Vulkan::Vulkan)

# Set C++ standard
set_property(TARGET "${TARGET_NAME}" PROPERTY CXX_STANDARD 20)
