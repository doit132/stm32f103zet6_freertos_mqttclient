-- project_name 被子目录下的 xmake.lua 需要, 所以这个变量不能设置成 local
g_project_name = "STM32F103_Pro"

-- 这里只所以再用 project 等于 project_name, 而不是直接使用 project_name, 是因为会报 error: attempt to concatenate a nil value (global 'project_name') 错误
local project_name = g_project_name
local target_dir = "build"
local ldscript_file_path = "User/src/STM32F103XE_FLASH.ld"
local sdk_folder_path = "C:/Users/doit132/scoop/apps/gcc-arm-none-eabi/current"
local bin_folder_path = sdk_folder_path.."/bin"
local cross_compiler_prefix = "arm-none-eabi"

local objdump = cross_compiler_prefix .. "-objdump"
local objcopy = cross_compiler_prefix .. "-objcopy"
local size = cross_compiler_prefix .. "-size"

add_rules("mode.debug", "mode.release", "mode.releasedbg", "mode.minsizerel")
set_defaultmode("unset")

set_config("plat","cross")

-- 生成 compile_commands.json 文件
add_rules("plugin.compile_commands.autoupdate", {outputdir = "./"})

-- 自定义工具链
toolchain(cross_compiler_prefix)
    -- 标记为独立工具链
    set_kind("standalone")
    -- 定义交叉编译工具链地址
    set_sdkdir(sdk_folder_path)
    set_bindir(bin_folder_path)
    -- set_toolset("cc", "arm-none-eabi-gcc")
    -- set_toolset("cxx", "arm-none-eabi-g++")
    -- set_toolset("as", "arm-none-linux-gnueabihf-as")
    -- 不能设置 ld , 因为一旦设置了这个东西, 它会弹出 unrecognised emulation mode: xxxx, 就是一些编译选项无法识别, 除非将 ld 设置成 arm-none-linux-gnueabihf-gcc
    -- set_toolset("ld", "arm-none-linux-gnueabihf-ld")
toolchain_end()

includes("Drivers/BSP/xmake.lua")
-- includes("Drivers/CMSIS/xmake.lua")
-- includes("Drivers/STM32MP1xx_HAL_Driver/xmake.lua")
-- includes("Drivers/SYSTEM/xmake.lua")
includes("User/xmake.lua")

-- #TODO basic board info
target(project_name)
    -- 之所以使用变量, 是因为在多处使用到相同的值, 为了更改方便, 使用了变量
    local CPU = "-mcpu=cortex-m3"
    local FPU = "-mfpu=fpv4-sp-d16 -mfloat-abi=soft"
    local LDSCRIPT = ldscript_file_path
    local cflags = {
        CPU,
        FPU,
        "--specs=nano.specs -specs=rdimon.specs --specs=nosys.specs -Wall -fmessage-length=0",
        "-mthumb",
        "-fdata-sections -ffunction-sections",
        "-nostartfiles",
        "-fno-builtin",
        -- 下面这个优化选项, 会导致 delay 延时出问题, 如果有下面这个优化选项, 延时形参必须 volatile 修饰
        -- "-Os",
    }
    local asflags = {
        CPU,
        FPU,
        "-mthumb",
        "-fdata-sections -ffunction-sections",
    }
    local ldflags = {
        CPU,
        FPU,
        "-mthumb",
        -- 链接脚本
        "-T"..LDSCRIPT,
        -- 链接库文件
        "-lc",
        "-lm",
        "-nostdlib",
        -- 产生的依赖文件存放位置
        "-Wl,-Map=" .. target_dir .. "/" .. project_name .. ".map,--cref -Wl,--gc-sections",
    }
    add_defines("USE_HAL_DRIVER", "CORE_CM3", "STM32MP157Dxx")
    add_cflags(cflags, {force = true})
    add_asflags(asflags, {force = true})
    add_ldflags(ldflags, {force = true})
target_end()

-- other config
target(project_name)
    set_targetdir(target_dir)
    set_objectdir(target_dir .. "/obj")
    set_dependir(target_dir .. "/dep")
    set_kind("binary")
    set_extension(".elf")

    add_toolchains(cross_compiler_prefix)
    set_warnings("all")
    set_languages("c11", "cxx17")

    if is_mode("debug") then
        set_symbols("debug")
        add_cxflags("-Og", "-gdwarf-2", {force = true})
        add_asflags("-Og", "-gdwarf-2", {force = true})
    elseif is_mode("release") then
        set_symbols("hidden")
        set_optimize("fastest")
        set_strip("all")
    elseif is_mode("releasedbg") then
        set_optimize("faster")
        set_symbols("debug")
        set_strip("all")
    elseif is_mode() then
        set_symbols("hidden")
        set_optimize("smallest")
        set_strip("all")
    end
target_end()

after_build(
    function(target)
        import("core.project.task")
        cprint("${bright green onwhite}${ok_hand} 储存空间占用情况 ${ok_hand}")
        -- xmake 无法执行 objdump 命令生成反汇编文件, 报错 file not fount
        -- os.exec(string.format("%s -D %s.elf > %s.dis", objdump, target_dir .. '/' .. project_name, target_dir .. '/' .. project_name))
        os.exec(string.format("%s -O ihex %s.elf %s.hex", objcopy, target_dir .. '/' .. project_name, target_dir .. '/' .. project_name))
        os.exec(string.format("%s -O binary %s.elf %s.bin", objcopy, target_dir .. '/' .. project_name, target_dir .. '/' .. project_name))
        os.exec(string.format("%s -Ax %s.elf", size, target_dir .. '/' .. project_name))
        os.exec(string.format("%s -Bd %s.elf", size, target_dir .. '/' .. project_name))
    end
)

