@echo off
REM //---------- 自定义Unreal项目编译脚本 ----------
REM // 本脚本用于指定Unreal Engine路径并编译AirSim的Blocks项目

setlocal EnableDelayedExpansion

REM // 设置默认参数
set "UE_PATH=E:\UE_4.27"
set "BUILD_CONFIG=DebugGame_Editor"
set "PLATFORM=x64"
set "AIRSIM_PROJECT_PATH=%~dp0"

REM // 处理命令行参数
if not "%1"=="" set "UE_PATH=%1"
if not "%2"=="" set "BUILD_CONFIG=%2"
if not "%3"=="" set "PLATFORM=%3"

REM // 检查Unreal Engine路径是否存在
if not exist "%UE_PATH%\Engine\Binaries\Win64\UE4Editor.exe" (
    echo 错误：未找到Unreal Engine路径 %UE_PATH%
    echo 请确认UE引擎安装在正确的位置，或通过命令行参数指定正确路径
    echo 用法：build_with_custom_ue.bat [UE_ENGINE_PATH] [BUILD_CONFIG] [PLATFORM]
    echo 示例：build_with_custom_ue.bat "E:\UE_4.27" DebugGame_Editor x64
    pause
    exit /b 1
)

REM // 显示当前配置
cls
 echo ======================================================
 echo           AirSim Unreal项目编译脚本
 echo ======================================================
 echo Unreal Engine 路径: %UE_PATH%
 echo 项目路径: %AIRSIM_PROJECT_PATH%
 echo 构建配置: %BUILD_CONFIG%
 echo 平台: %PLATFORM%
 echo ======================================================
 echo. 

REM // 导航到项目目录
cd /d "%AIRSIM_PROJECT_PATH%"

REM // 清理项目
echo 正在清理项目...
if exist clean.bat (
    call clean.bat
) else (
    echo 警告: 未找到clean.bat，跳过清理步骤
)

REM // 更新AirSim插件
if exist update_from_git.bat (
    echo 正在更新AirSim插件...
    call update_from_git.bat ..\..\..
) else (
    echo 警告: 未找到update_from_git.bat，跳过更新步骤
)

REM // 使用指定的UE引擎生成项目文件
echo 正在生成项目文件...
"%UE_PATH%\Engine\Binaries\DotNET\UnrealBuildTool.exe" -projectfiles -project="%AIRSIM_PROJECT_PATH%Blocks.uproject" -game -rocket -progress

REM // 检查生成是否成功
if not exist "%AIRSIM_PROJECT_PATH%Blocks.sln" (
    echo 错误：项目文件生成失败
    pause
    exit /b 1
)

REM // 编译项目
REM // 查找Visual Studio路径
set "VS_PATH="
for /f "tokens=2* skip=2" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\SxS\VS7" /v "17.0" 2^>nul') do set "VS_PATH=%%b"

if "%VS_PATH%"=="" (
    echo 警告：未找到Visual Studio 2022安装路径
    echo 尝试使用系统PATH中的devenv.com...
    set "VS_BUILD_TOOL=devenv.com"
) else (
    set "VS_BUILD_TOOL=%VS_PATH%Common7\IDE\devenv.com"
)

REM // 使用Visual Studio构建项目
if exist "%VS_BUILD_TOOL%" (
    echo 正在使用Visual Studio构建项目...
    "%VS_BUILD_TOOL%" "%AIRSIM_PROJECT_PATH%Blocks.sln" /Build "%BUILD_CONFIG%|%PLATFORM%"
) else (
    echo 警告：未找到Visual Studio构建工具
    echo 尝试使用MSBuild构建...
    msbuild "%AIRSIM_PROJECT_PATH%Blocks.sln" /p:Configuration=%BUILD_CONFIG% /p:Platform=%PLATFORM% /m
)

REM // 检查构建是否成功
if errorlevel 1 (
    echo 错误：项目构建失败
    pause
    exit /b 1
)

REM // 构建成功后的提示
 echo.
 echo ======================================================
 echo            项目编译成功！
 echo ======================================================
 echo 下一步操作：
 echo 1. 双击打开 %AIRSIM_PROJECT_PATH%Blocks.sln
 echo 2. 确保Blocks项目是启动项目
 echo 3. 设置构建配置为 %BUILD_CONFIG%
 echo 4. 平台设置为 %PLATFORM%
 echo 5. 按F5运行Unreal Editor
 echo 6. 在Unreal Editor中点击Play按钮开始模拟
 echo ======================================================
 pause

exit /b 0