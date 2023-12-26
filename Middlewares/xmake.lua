target(g_project_name)
    add_files(
        "Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2/*.c",
        "Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM3/*.c",
        "Third_Party/FreeRTOS/Source/portable/MemMang/*.c",
        "Third_Party/FreeRTOS/Source/*.c"
    )

    remove_files(
    )

    add_includedirs(
        "Third_Party/FreeRTOS/Source/include",
        "Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2",
        "Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM3"
    )
target_end()
