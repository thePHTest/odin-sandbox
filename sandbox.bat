@echo off
set bat_dir=%~dp0
pushd %bat_dir%
pushd bin
call ..\build\win32_sandbox.exe
popd
popd
