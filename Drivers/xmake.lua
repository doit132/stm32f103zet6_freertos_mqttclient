target(g_project_name)
    add_files(
        "STM32F1xx_HAL_Driver/Src/*.c"
    )

    remove_files(
    )

    add_includedirs(
        "CMSIS/Include",
        "CMSIS/Device/ST/STM32F1xx/Include",
        "STM32F1xx_HAL_Driver/Inc",
        "STM32F1xx_HAL_Driver/Inc/Legacy"
    )
target_end()
