include(${CMAKE_CURRENT_LIST_DIR}/debug.cmake)
debug_position(CMakeDetermineASM_PICCompiler.cmake ${CMAKE_CURRENT_LIST_LINE})

# This is a script file to generate a custom-compiler YAML for CLion
cmake_minimum_required(VERSION 3.19)

macro(increment var)
    math(EXPR ${var} "${${var}} + 1")
endmacro()

if (NOT DEFINED CMAKE_CURRENT_BINARY_DIR)
    message(FATAL_ERROR "CMAKE_CURRENT_BINARY_DIR undefined")
endif ()

set(compile_commands "${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json")
# file(STRINGS ...) throws an error if file doesn't exist, using CMake's internal `cat` instead
execute_process(RESULT_VARIABLE result OUTPUT_VARIABLE json ERROR_QUIET COMMAND ${CMAKE_COMMAND} -E cat ${compile_commands})

if (NOT result EQUAL 0)
    message(FATAL_ERROR "${compile_commands} doesn't exist, make sure that project's CMakeLists.txt defines any compilable targets")
else ()
    string(JSON json ERROR_VARIABLE error GET ${json} 0)
    if (NOT "NOTFOUND" STREQUAL "${error}")
        message(FATAL_ERROR "${compile_commands}:\n${error}")
    else ()
        string(JSON command ERROR_VARIABLE error GET ${json} "command")
        if (NOT "NOTFOUND" STREQUAL "${error}")
            message(FATAL_ERROR "${compile_commands}:\n${error}")
        else ()

            # NOTE: here is a command string to compile first source file in project
            separate_arguments(split NATIVE_COMMAND "${command}")
            list(LENGTH split size)

            if (${size} LESS 2)
                message(FATAL_ERROR "Malformed command\n${command}")
            else ()
                list(GET split 0 executable)
                unset(args)
                unset(suffix)

                set(index 1)
                math(EXPR last_index "${size} - 1")
                while (${index} LESS ${size})
                    list(GET split ${index} arg)
                    if (${arg} STREQUAL "-std=c89" OR ${arg} STREQUAL "-std=c90")
                        set(std90 TRUE)
                    elseif (${arg} STREQUAL "-o")
                        increment(index)
                    elseif (${index} EQUAL ${last_index})
                        # get default source extension
                        list(GET split ${index} arg)
                        string(REGEX MATCH "\\.(c|cpp)$" suffix "${arg}")
                    else ()
                        if (${arg} MATCHES "^-mcpu")
                            # get chip
                            string(REGEX MATCH "[^=]+$" chip "${arg}")
                        endif ()
                        list(APPEND args "${arg}")
                    endif ()
                    increment(index)
                endwhile ()

                if (NOT DEFINED chip)
                    message(FATAL_ERROR "Compile command doesn't contain '-mcpu=' option, can't detect chip")
                else ()
                    if (NOT suffix)
                        message(WARNING "Compile command for the first source file in the project\n${command}\ndoesn't contain a C/C++ source")
                        set(suffix ".c")
                    endif ()
                    # options to get verbose output, note that '-std=c99' is mandatory for any standard
                    list(APPEND args -std=c99 -v -E -c "dummy${suffix}")
                    # generate temporary source file
                    file(WRITE "dummy${suffix}" "int main() { return 0; }\n")
                    execute_process(RESULT_VARIABLE result OUTPUT_VARIABLE output ERROR_VARIABLE output COMMAND ${executable} ${args})
                    file(REMOVE "dummy${suffix}")

                    if (NOT 0 EQUAL ${result})
                        message(FATAL_ERROR "Error executing ${executable} ${args}")
                    else ()
                        set(yaml ""
                                "compilers:"
                                "  - description: Microchip MPLAB XC8 C Compiler"
                                "    match-compiler-exe: \"(.*/)?xc8-cc(\\\\.exe)?\""
                                "    code-insight-target-name: pic"
                                )

                        # define stubs for non standard language extensions
                        set(defines
                                "__asm(...):"
                                "__bank(...):"
                                "__bank0:"
                                "__bank1:"
                                "__bank2:"
                                "__bank3:"
                                "__bit: char"
                                "__compiled:"
                                "__config(...):"
                                "__control:"
                                "__eeprom:"
                                "__far:"
                                "__int24: long"
                                "__interrupt(...):"
                                "__near:"
                                "__nonreentrant:"
                                "__nop(...):"
                                "__persistent:"
                                "__ram:"
                                "__reentrant:"
                                "__rom:"
                                "__section(...):"
                                "__software:"
                                "__uint24: unsigned long"
                                )

                        separate_arguments(split NATIVE_COMMAND "${output}")
                        foreach (chunk ${split})
                            # find compiler parameters list [arguments]
                            if (${chunk} MATCHES "^\\[;.*;\\]$" AND ${chunk} MATCHES ";-isystem")
                                string(REGEX REPLACE "^\\[;|\\;]$" "" chunk ${chunk})
                                foreach (arg ${chunk})
                                    if (${arg} MATCHES "^-D")
                                        string(REGEX REPLACE "^-D" "" define ${arg})
                                        if (${define} MATCHES "=")
                                            string(REPLACE "=" ": " define ${define})
                                        else ()
                                            string(APPEND define ":")
                                        endif ()
                                        list(APPEND defines "${define}")
                                    elseif (${arg} MATCHES "^-isystem")
                                        string(REGEX REPLACE "^-isystem" "" include ${arg})
                                        file(TO_CMAKE_PATH ${include} include)
                                        string(REPLACE "//" "/" include ${include})
										# rewrite c99 directory if using lower standard
										if (${std90} AND ${include} MATCHES "/include/c99$")
											string(REPLACE "/c99" "/c90" include ${include})
										endif()
                                        # copy includes to avoid extensive [and recursive] indexing
                                        string(REGEX MATCH "/(include(/.+)?)$" dir "${include}")
                                        set(dir ${CMAKE_MATCH_1})
                                        set(include_copy "${CMAKE_BINARY_DIR}/xc8/${dir}")
                                        if (${dir} MATCHES "^include/(proc|legacy)$")
                                            file(GLOB include_files "${include}/*${chip}*.*")
                                        else ()
                                            file(GLOB include_files "${include}/*.*")
                                        endif ()
                                        file(MAKE_DIRECTORY ${include_copy})
                                        file(COPY ${include_files} DESTINATION ${include_copy})
                                        # additionally copy c99 subdirs
                                        if (${dir} MATCHES "^include/c99$")
                                            file(MAKE_DIRECTORY "${include_copy}/bits")
                                            file(GLOB include_files "${include}/bits/*.*")
                                            file(COPY ${include_files} DESTINATION "${include_copy}/bits")
                                            file(MAKE_DIRECTORY "${include_copy}/sys")
                                            file(GLOB include_files "${include}/sys/*.*")
                                            file(COPY ${include_files} DESTINATION "${include_copy}/sys")
                                        endif ()
                                        unset(include_files)
                                        set(include ${include_copy})
                                        unset(include_copy)
                                        list(APPEND includes "      - \"${include}\"")
                                    endif ()
                                endforeach ()
                            endif ()
                        endforeach ()

                        list(APPEND yaml "    include-dirs:" ${includes})
                        list(APPEND yaml "    defines:")
                        list(REMOVE_DUPLICATES defines)
                        foreach (define ${defines})
                            list(APPEND yaml "      ${define}")
                        endforeach ()
                        list(APPEND yaml "")
                        list(JOIN yaml "\n" yaml)

                        set(filename "${DIR}/XC8.yaml")
                        file(WRITE ${filename} ${yaml})
                        message("*** Successfully generated ${filename} ***")
                    endif ()

                endif ()
            endif ()

        endif ()
    endif ()
endif ()
