@echo off
set bat_dir=%~dp0
pushd %bat_dir%
IF NOT EXIST .\bin mkdir .\bin
pushd bin
call ..\build\win32_sandbox.exe
popd
popd
