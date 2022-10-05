include(${CMAKE_CURRENT_LIST_DIR}/debug.cmake)
debug_position(${CMAKE_CURRENT_LIST_FILE} ${CMAKE_CURRENT_LIST_LINE})

# NOTE: runs once when cache created!
# this should find the compiler for LANG and configure CMake(LANG)Compiler.cmake.in

include(${CMAKE_CURRENT_LIST_DIR}/common.cmake)
# find the compiler
find_compiler(C XC8 "xc8-cc;" "${XC8_PATH_HINTS}" "c;xc" .p1 YES 8)
# create cache config
configure_compiler(C)
