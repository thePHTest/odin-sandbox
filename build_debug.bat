@echo off
set bat_dir=%~dp0
pushd %bat_dir%
IF NOT EXIST .\debug_build mkdir .\debug_build
pushd debug_build
odin build ../src/win32_sandbox.odin -debug
odin build ../src/app_sandbox.odin -debug -build-mode:dll
popd popd
