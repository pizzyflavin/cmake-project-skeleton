
##############################
# Convert ELF to binary file #
##############################

function(convert_to_hex TARGET)
    add_custom_command(
        TARGET ${TARGET} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O ihex ${TARGET} ${TARGET}.hex
        BYPRODUCTS ${TARGET}.hex
    )
endfunction()

#################################
# Convert ELF to Intel Hex file #
#################################

function(convert_to_bin TARGET)
    add_custom_command(
        TARGET ${TARGET} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O binary ${TARGET} ${TARGET}.bin
        BYPRODUCTS ${TARGET}.bin
    )
endfunction()

