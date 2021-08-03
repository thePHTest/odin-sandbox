@echo off
set bat_dir=%~dp0
pushd %bat_dir%
IF NOT EXIST .\build mkdir .\build
pushd build
odin build ../src/win32_sandbox.odin
odin build ../src/app_sandbox.odin -build-mode:dll
popd popd
