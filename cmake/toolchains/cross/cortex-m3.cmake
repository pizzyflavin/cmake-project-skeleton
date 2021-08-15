########################
# Cortex-M3 Soft Float #
########################
if(ARM_CORTEX_M3_TOOLCHAIN_INCLUDED)
    return()
endif()

if(NOT CPU_NAME)
    set(CPU_NAME cortex-m3)
endif()

set(CPU_FLAGS "-mcpu=cortex-m3 -mthumb --specs=nosys.specs --specs=nano.specs ${CPU_FLAGS}")
set(VFP_FLAGS "-mfloat-abi=soft ${VFP_FLAGS}")

# Include arm-none-eabi base file
include(${CMAKE_CURRENT_LIST_DIR}/arm-none-eabi-gcc.cmake)

set(ARM_CORTEX_M3_TOOLCHAIN_INCLUDED true)

