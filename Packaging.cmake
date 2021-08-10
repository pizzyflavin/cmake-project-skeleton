###################
# Packaging Rules #
###################

### General Configuration ###

set(CPACK_PACKAGE_VENDOR "Embedded Artistry")
set(CPACK_GENERATOR "ZIP;TBZ2")
set(CPACK_PACKAGE_DIRECTORY "${CMAKE_BINARY_DIR}/packages")

set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${CMAKE_SYSTEM_PROCESSOR}")
if(CPU_NAME)
    set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_FILE_NAME}-${CPU_NAME}")
endif()
if(NOT "${CMAKE_SYSTEM_NAME}" STREQUAL "Generic")
    set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_FILE_NAME}-${CMAKE_SYSTEM_NAME}")
endif()
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_FILE_NAME}-${CMAKE_PROJECT_VERSION}")

######################################
### Source Packaging Configuration ###
######################################

set(CPACK_SOURCE_GENERATOR "ZIP;TBZ2")
set(CPACK_SOURCE_IGNORE_FILES
    "${CMAKE_BINARY_DIR}"
    ".DS_Store"
    "/.git*/"
)

### INCLUDE ALL SETTINGS BEFORE THIS LINE
include(CPack)

