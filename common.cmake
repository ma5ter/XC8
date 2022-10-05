include(${CMAKE_CURRENT_LIST_DIR}/debug.cmake)
debug_position(CMakeDetermineASM_PICCompiler.cmake ${CMAKE_CURRENT_LIST_LINE})

# This is a common file to be shared among different languages
cmake_minimum_required(VERSION 3.10)

macro(find_compiler lang id names hint_paths source_exts output_ext ext_replace linker_pref)
    # required internal CMake variable
    set(CMAKE_${lang}_COMPILER_ENV_VAR "")
    # required internal CMake variable for some languages e.q. C
    set(CMAKE_${lang}_COMPILER_ID ${id})
    # reset all the initials if been set
    set(CMAKE_${lang}_FLAGS_INIT "")
    set(CMAKE_${lang}_FLAGS "")
    # define file extensions
    set(CMAKE_${lang}_SOURCE_FILE_EXTENSIONS ${source_exts})
    set(CMAKE_${lang}_OUTPUT_EXTENSION ${output_ext})
    # whether this language wants to replace the source extension with the object extension
    # if false output extension will be simply appended like source.c.o
    set(CMAKE_${lang}_OUTPUT_EXTENSION_REPLACE ${ext_replace})
    # instead of setting LINKER_LANGUAGE set LINKER_PREFERENCE
    # Hints here:
    # https://cmake.org/cmake/help/latest/prop_tgt/LINKER_LANGUAGE.html
    # https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_LINKER_PREFERENCE.html
    set(CMAKE_${lang}_LINKER_PREFERENCE ${linker_pref})
    # left undefined
    unset(CMAKE_${lang}_COMPILER)
    unset(CMAKE_${lang}_COMPILER_AR)
    unset(CMAKE_${lang}_COMPILER_RANLIB)
    # find executable
    find_program(compiler ${names} PATHS ${hint_paths})
    if ("${compiler}" STREQUAL "compiler-NOTFOUND")
        message(FATAL_ERROR "Compiler binary ${names} not found!")
    else ()
        message(STATUS "Binary found at ${compiler}")
        set(CMAKE_${lang}_COMPILER ${compiler})
        set(CMAKE_${lang}_COMPILER_LOADED TRUE)
    endif ()
endmacro()

macro(configure_compiler lang)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/CMake${lang}Compiler.cmake.in
            ${CMAKE_PLATFORM_INFO_DIR}/CMake${lang}Compiler.cmake @ONLY)
endmacro()
