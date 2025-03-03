set WORKING_DIR=%CD%
set CONFIG=%1
cd %~dp0
if /I "%CONFIG%" == "" (set CONFIG=Release)

@echo "Creating build directory..."
mkdir build > nul

@echo "Generating project files..."
cd build

@REM Note that we pass the CMAKE_BUILD_TYPE here only to enable the correct
@REM build of the external projects. Visual Studio doesn't honour this when
@REM configuring the makefile - it only honours it as a --config flag to cmake
@REM itself. We therefore pass this via --config in the win0build-gui.bat file
@REM explicitly, but as we also pass it in here it will be used by the cmake
@REM build files for app/external

cmake -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=%CONFIG% -DKISSFFT_TOOLS=OFF -DKISSFFT_PKGCONFIG=OFF ..\
if %ERRORLEVEL% neq 0 (
    cd %WORKING_DIR%
    exit /b %ERRORLEVEL%
)

cd %WORKING_DIR%
