# PowerShell script to launch UE4 Editor for AirSim Blocks environment
# This script opens the project in UE4 Editor, which will handle building automatically

param(
    [string]$UE4Path = "E:\UE_4.27"
)

# Set output encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Check if UE4.27 path exists
if (-not (Test-Path -Path "$UE4Path\Engine\Binaries\Win64\UE4Editor.exe")) {
    Write-Host "Error: Cannot find UE4.27 installation at: $UE4Path" -ForegroundColor Red
    Write-Host "Please ensure UE4.27 is installed at this path or specify the correct path with -UE4Path parameter" -ForegroundColor Yellow
    exit 1
}

# Set project paths
try {
    $ProjectDir = Join-Path -Path $PSScriptRoot -ChildPath "..\Unreal\Environments\Blocks"
    $ProjectFile = Join-Path -Path $ProjectDir -ChildPath "Blocks.uproject"
} catch {
    Write-Host "Error: Failed to resolve project path" -ForegroundColor Red
    Write-Host "Detailed error: $_" -ForegroundColor Yellow
    exit 1
}

# Check if project file exists
if (-not (Test-Path -Path $ProjectFile)) {
    Write-Host "Error: Cannot find project file: $ProjectFile" -ForegroundColor Red
    exit 1
}

Write-Host "=======================================================" -ForegroundColor Green
Write-Host "          Launching AirSim Blocks Environment" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green
Write-Host "Using UE4 Editor to handle the build process" -ForegroundColor Yellow
Write-Host "Unreal Engine Path: $UE4Path" -ForegroundColor Cyan
Write-Host "Project Path: $ProjectFile" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Green
Write-Host "Launching UE4 Editor..." -ForegroundColor Yellow

# Set up paths for UE4 Editor
try {
    $UE4EditorPath = Join-Path -Path $UE4Path -ChildPath "Engine\Binaries\Win64\UE4Editor.exe"
    
    if (-not (Test-Path -Path $UE4EditorPath)) {
        throw "Cannot find UE4 Editor at: $UE4EditorPath"
    }
    
    # Use absolute paths for better reliability
    $AbsoluteProjectFile = Resolve-Path -Path $ProjectFile
    
    # Launch UE4 Editor with the project
    # This will automatically build any required components
    Write-Host "Running command: $UE4EditorPath $AbsoluteProjectFile" -ForegroundColor Magenta
    Start-Process -FilePath "$UE4EditorPath" -ArgumentList "`"$AbsoluteProjectFile`"" -NoNewWindow
    
    # Check if launch was successful
    if (-not $?) {
        throw "Failed to launch UE4 Editor"
    }
    
    Write-Host "=======================================================" -ForegroundColor Green
    Write-Host "          UE4 Editor Launched Successfully!" -ForegroundColor Green
    Write-Host "=======================================================" -ForegroundColor Green
    Write-Host "UE4 Editor will now automatically build any required components." -ForegroundColor Cyan
    Write-Host "This may take some time depending on your system." -ForegroundColor Cyan
} catch {
    Write-Host "=======================================================" -ForegroundColor Red
    Write-Host "          Failed to Launch UE4 Editor!" -ForegroundColor Red
    Write-Host "Error message: $_" -ForegroundColor Red
    Write-Host "Please try launching the project manually by double-clicking: $ProjectFile" -ForegroundColor Yellow
    Write-Host "=======================================================" -ForegroundColor Red
    exit 1
}

# Next steps
Write-Host "
Next Steps:
1. Wait for UE4 Editor to finish loading and building the project
2. In the UE4 Editor, click the Play button to start simulation
3. Alternatively, you can press F5 in VS Code to run the editor
" -ForegroundColor Yellow

# Pause for user to view output
Read-Host -Prompt "Press Enter to exit"