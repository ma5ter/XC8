include(${CMAKE_CURRENT_LIST_DIR}/debug.cmake)
debug_position(${CMAKE_CURRENT_LIST_FILE} ${CMAKE_CURRENT_LIST_LINE})

# CMake(LANG)Information.cmake  -> set up rule variables for LANG :
#   CMAKE_(LANG)_CREATE_SHARED_LIBRARY
#   CMAKE_(LANG)_CREATE_SHARED_MODULE
#   CMAKE_(LANG)_CREATE_STATIC_LIBRARY
#   CMAKE_(LANG)_COMPILE_OBJECT
#   CMAKE_(LANG)_LINK_EXECUTABLE

set(CMAKE_C_CREATE_SHARED_LIBRARY "")
set(CMAKE_C_CREATE_SHARED_MODULE "")
set(CMAKE_C_CREATE_STATIC_LIBRARY "")
set(CMAKE_C_COMPILE_OBJECT "<CMAKE_C_COMPILER> <FLAGS> <DEFINES> <INCLUDES> -o <OBJECT> <SOURCE>")
set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_C_COMPILER> <FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")

# NOTE: CMake has no CMAKE_<LANG>_LINK_FLAGS, just LINK_FLAGS

# CMAKE_C_FLAGS. This value is a command-line string fragment.
# Therefore, multiple options should be separated by spaces, and options with
# spaces should be quoted.
# This will later be used to populate <FLAGS>

set(CMAKE_C_FLAGS "-mcpu=${CHIP} --nofallback")

if (XC8_OBJ)
    set(CMAKE_C_OUTPUT_EXTENSION .o)
else()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -c")
endif ()

if (CMAKE_VERBOSE_MAKEFILE)
    message(STATUS "Enabled verbose C compiler output")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -v")
endif ()

if (CMAKE_C_STANDARD EQUAL 89 OR CMAKE_C_STANDARD EQUAL 90)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c90")
elseif (CMAKE_C_STANDARD EQUAL 99)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99")
else ()
    message(FATAL_ERROR "Unsupported C standard '${CMAKE_C_STANDARD}'")
endif ()
