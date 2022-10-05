set(EMBEDDED_DEBUG TRUE)
include(${CMAKE_CURRENT_LIST_DIR}/debug.cmake)
debug_position(XC8.cmake ${CMAKE_CURRENT_LIST_LINE})

cmake_minimum_required(VERSION 3.10)

# check if chip is set
if(NOT DEFINED CHIP)
    message(FATAL_ERROR "CHIP is not defined")
endif()
message(STATUS "Target chip is ${CHIP}")

# set path hints
if (DEFINED XC8_VERSION)
    set(XC8_PATH_HINTS "/opt/microchip/xc8/${XC8_VERSION}/bin;C:/Program Files/Microchip/xc8/v${XC8_VERSION}/bin")
endif ()

# RTFM:
# https://cmake.org/cmake/help/latest/variable/CMAKE_MODULE_PATH.html
# share/cmake-3.*/Modules/CMakeAddNewLanguage.txt
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION "1")
set(CMAKE_SYSTEM_PROCESSOR "PIC")
set(CMAKE_CROSSCOMPILING "TRUE")

# executable suffix
set(CMAKE_EXECUTABLE_SUFFIX .elf)

# disable building shared libraries for OS-less systems
set_property(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS FALSE)

# Static library tools
# not yet implemented
set(CMAKE_AR "")
set(CMAKE_RANLIB "")
set(CMAKE_ADDR2LINE "")
set(CMAKE_NM "")
set(CMAKE_OBJCOPY "")
set(CMAKE_OBJDUMP "")
set(CMAKE_STRIP "")

# no default linker
set(CMAKE_LINKER "")

# no install rules
set(CMAKE_SKIP_INSTALL_RULES TRUE)

# target to generate custom-compiler YAML
set(CMAKE_EXPORT_COMPILE_COMMANDS true)
add_custom_target(CLion-YAML
        COMMAND ${CMAKE_COMMAND} -D DIR=${CMAKE_SOURCE_DIR} -P ${CMAKE_CURRENT_LIST_DIR}/yaml.cmake
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        VERBATIM)
