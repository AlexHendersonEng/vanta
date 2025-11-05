# Add all subdirectories of a given base directory to the build
function(add_all_subdirectories)
    # Get list of all subdirectories
    file(GLOB SUB_DIRECTORIES LIST_DIRECTORIES true "${CMAKE_CURRENT_SOURCE_DIR}/*")

    # Loop over subdirectories and add them to the build
    foreach(SUB_DIRECTORY ${SUB_DIRECTORIES})
        if(IS_DIRECTORY "${SUB_DIRECTORY}" AND EXISTS "${SUB_DIRECTORY}/CMakeLists.txt")
            message(STATUS "Adding subdirectory: ${SUB_DIRECTORY}")
            add_subdirectory("${SUB_DIRECTORY}")
        endif()
    endforeach()
endfunction()

# Compile shaders
function(compile_shaders SHADER_DIR SPIRV_DIR TARGET_NAME)
    # Find glslc executable
    find_program(
        GLSLC_EXECUTABLE
        NAMES glslc
    )
    if(NOT GLSLC_EXECUTABLE)
        message(FATAL_ERROR "glslc not found! Please install Vulkan SDK.")
    endif()

    # Find all shaders
    file(GLOB SHADERS "${SHADER_DIR}/*.vert" "${SHADER_DIR}/*.frag")

    # Add custom command to compile shaders
    foreach(SHADER ${SHADERS})
        get_filename_component(FILE_NAME ${SHADER} NAME)
        set(SPIRV_FILE ${SPIRV_DIR}/${FILE_NAME}.spv)

        add_custom_command(
            OUTPUT ${SPIRV_FILE}
            COMMAND ${GLSLC_EXECUTABLE} ${SHADER} -o ${SPIRV_FILE}
            DEPENDS ${SHADER}
            COMMENT "Compiling shader ${FILE_NAME} into ${SPIRV_FILE}"
            VERBATIM
        )

        list(APPEND COMPILED_SHADERS ${SPIRV_FILE})
    endforeach()

    # Create custom target for shader compilation
    add_custom_target(shaders DEPENDS ${COMPILED_SHADERS})

    # Add shader compilation target as a dependency
    add_dependencies("${TARGET_NAME}" shaders)
endfunction()
