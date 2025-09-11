@echo off
setlocal enableextensions
REM Locate VS 2022 installation using vswhere and initialize x64 Native Tools, then run build.cmd

set VSWHERE="C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist %VSWHERE% (
  echo ERROR: vswhere.exe not found at %VSWHERE%
  exit /b 1
)

for /f "usebackq tokens=* delims=" %%I in (`%VSWHERE% -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set VSINSTALL=%%I

if not defined VSINSTALL (
  echo ERROR: Could not detect Visual Studio installation path.
  exit /b 1
)

set VSCMD="%VSINSTALL%\Common7\Tools\VsDevCmd.bat"
if not exist %VSCMD% (
  echo ERROR: VsDevCmd.bat not found at %VSCMD%
  exit /b 1
)

call %VSCMD% -arch=x64 -host_arch=x64
if errorlevel 1 (
  echo ERROR: Failed to initialize VS developer command prompt.
  exit /b 1
)

call "%~dp0build.cmd"
exit /b %errorlevel%

