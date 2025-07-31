@echo off
setlocal enabledelayedexpansion

:: === CONFIG ===
set FFMPEG=ffmpeg.exe

:: === LOOP THROUGH CLEAN .MP4 FILES ===
for /R %%F in (*.mp4) do (
    set "filename=%%~nxF"
    echo !filename! | findstr /R "\.f[0-9][0-9][0-9]\.mp4 \.part\.mp4" >nul
    if !errorlevel! == 1 (
        set "input=%%F"
        set "folder=%%~dpF"
        set "originalName=%%~nF"
        call :SanitizeName "%%~nF"
        call :ConvertToHLS
    )
)
goto :eof

:SanitizeName
:: Sanitize only the video name
set "safeName=%~1"
set "safeName=!safeName: =_!"
set "safeName=!safeName:ç=c!"
set "safeName=!safeName:Ç=C!"
set "safeName=!safeName:ã=a!"
set "safeName=!safeName:Ã=A!"
set "safeName=!safeName:á=a!"
set "safeName=!safeName:Á=A!"
set "safeName=!safeName:é=e!"
set "safeName=!safeName:É=E!"
set "safeName=!safeName:ê=e!"
set "safeName=!safeName:Ê=E!"
set "safeName=!safeName:í=i!"
set "safeName=!safeName:Í=I!"
set "safeName=!safeName:ó=o!"
set "safeName=!safeName:Ó=O!"
set "safeName=!safeName:ô=o!"
set "safeName=!safeName:Ô=O!"
set "safeName=!safeName:ú=u!"
set "safeName=!safeName:Ú=U!"
set "safeName=!safeName:ü=u!"
set "safeName=!safeName:Ü=U!"
set "safeName=!safeName:ñ=n!"
set "safeName=!safeName:Ñ=N!"
set "nameonly=!safeName!"
exit /b

:ConvertToHLS
echo.
echo ▶ Converting: !input!
set "outputdir=!folder!!nameonly!"
mkdir "!outputdir!" >nul 2>&1

:: Convert to HLS format
"%FFMPEG%" -i "!input!" -codec: copy -start_number 0 -hls_time 10 -hls_list_size 0 ^
-f hls "!outputdir!\!nameonly!.m3u8"

:: Move thumbnail if originalName.jpg exists
if exist "!folder!!originalName!.jpg" (
    move /Y "!folder!!originalName!.jpg" "!outputdir!\" >nul
)

:: Delete the original .mp4
del /Q "!input!"

:: Log result
echo [HLS DONE] !nameonly! >> hls-conversion-log.txt
exit /b
