include(${CMAKE_CURRENT_LIST_DIR}/debug.cmake)
debug_position(${CMAKE_CURRENT_LIST_FILE} ${CMAKE_CURRENT_LIST_LINE})

# CMakeTest(LANG)Compiler.cmake -> test the compiler and set:
#   set(CMAKE_(LANG)_COMPILER_WORKS 1 CACHE INTERNAL "")

# TODO: test actually works

set(CMAKE_C_COMPILER_WORKS 1 CACHE INTERNAL "")
