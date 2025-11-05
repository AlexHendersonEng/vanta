# Variables
set(TARGET_NAME "imgui_example")

# Get required packages
find_package(glfw3 REQUIRED)
find_package(glm CONFIG REQUIRED)
find_package(Vulkan REQUIRED)
find_package(imgui CONFIG REQUIRED)

# Add executable
add_executable("${TARGET_NAME}" "main.cpp")

# Link libraries
target_link_libraries("${TARGET_NAME}" PRIVATE glfw glm::glm Vulkan::Vulkan imgui::imgui)

# Set C++ standard
set_property(TARGET "${TARGET_NAME}" PROPERTY CXX_STANDARD 20)
