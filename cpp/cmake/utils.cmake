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
