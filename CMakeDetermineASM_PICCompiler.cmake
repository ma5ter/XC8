include(${CMAKE_CURRENT_LIST_DIR}/debug.cmake)
debug_position(${CMAKE_CURRENT_LIST_FILE} ${CMAKE_CURRENT_LIST_LINE})

# NOTE: runs once when cache created!
# this should find the compiler for LANG and configure CMake(LANG)Compiler.cmake.in

include(${CMAKE_CURRENT_LIST_DIR}/common.cmake)
# find the compiler
find_compiler(ASM_PIC XC8_ASM "xc8-cc;" "${XC8_PATH_HINTS}" "as;asm;s;S" .o YES 9)
# add include flag
set(CMAKE_INCLUDE_FLAG_ASM_PIC "-I")
# create cache config
configure_compiler(ASM_PIC)
