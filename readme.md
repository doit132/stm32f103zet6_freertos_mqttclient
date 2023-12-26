# 1. 配置基本文件

- 创建的基本文件有下面这些

  - .clang-format (格式化源码文件)
  - .gitignore
  - xmake.lua (替代 makefile 或 cmakelists.txt)
  - build.sh (编译脚本, 主要是将多个命令放到一起, 在 git bash 环境下运行)
  - clang-format.py (批量格式化脚本), 可以使用 clang-formatter.exe 来替代, clang-formatter.exe 格式化的速度更快
- .vscode 文件夹

  - settings.json
  - launch.json (用来 openocd 调试)
  - tasks.json

# 2. 配置 stm32f1 系列 hal 库

使用 stm32cubemax 生成一个 stm32f103zet6 的 makefile 项目
