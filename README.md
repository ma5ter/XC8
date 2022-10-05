# Microchip XC8
**Custom compiler Module for CMake**

*Being mature and popular CMake is not always clearly understood and well documented and not easily can be tuned when dealing with non standard environments.*

It was hard to find a 'legal' way to add support of custom compilers to the upstream CMake.
The only existing 'official way' to use an usupported by the CMake compiler is to define `CMAKE_SYSTEM_NAME` as `Generic`.

But there are many pitfalls inside the direct approach, and it is nearly unavailable to get a nice working mechanism instead of ugly compromise.

The key to the successful solution was a tiny text file `AddCustomLanguage.txt` inside `Modules` directory of the CMake where it was pointed out how to add 
a custom external module.

## Which is supported
This module supports Microchip XC8 embedded compiler.

Both C and ASM files.

### Some extras
This module also provides native CMake custom targets to produce `custom_compiler.yaml` files for the CLion IDE.

Note that support of custom compiler was implemented in CLion starting version `213.4928.11`.

## Installation
First of all just clone this repository into your project's folder (side by side to the main `CMakeLists.txt` file)

    git clone --depth 1 https://github.com/ma5ter/XC8.git

Alternatively add this repository as a submodule project:

    git submodule add https://github.com/ma5ter/XC8.git

In the project's `CMakeLists.txt` define a chip used as target, e.g.:
    
    set(CHIP 16f84)

Optionally set C-standard supported by the compiler    
    
    set(CMAKE_C_STANDARD 90)

When needed this may point to a specific compiler version
    
    set(XC8_VERSION 2.40)

Otherwise, compiler is found under the system `PATH`

Next include this Module into the project's `CMakeLists.txt` before any `project` that uses C or ASM_PIC languages:

    include(XC8/XC8.cmake)

And at last add `C` and `ASM_PIC` languages or one of them into the project, e.g.:

    project(test C ASM_PIC)

## Usage

Build works without any other efforts.

Run and debug is not supported by this framework and should be implemented as custom targets now.

When compiling bare assembler project to avoid generating and linking a startup file this flag may be passed to the linker:

    add_link_options(-nostartfiles)

Other flags to the `xc8-cc` frontend also work, e.g.:

    add_compile_options(-mstack=compiled -O2 -fasmfile)
    add_link_options(-mreserve=rom@3f80:3fff)

### Usage with CLion

Prior to be recognized as custom compiler a proper `custom_compiler.yaml` file should be created.<br>
This is done by building custom target of `CLion-YAML` which is supplied by the framework and produces compiler's yaml file in the project's folder.

Next a custom compiler should be set up in the IDE as described here:
> https://blog.jetbrains.com/clion/2021/10/clion-2021-3-eap-custom-compiler/#using_a_custom_compiler_in_clion

After that CLlion recognizes all the predefined macros and system include paths of the compiler and stops arguing about unsupported compiler.
