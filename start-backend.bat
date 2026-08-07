@echo off
setlocal
cd /d "%~dp0"
title Auto Label Detection - AI Backend (Port 83)

set "JAVA_EXE=D:\Java\jdk-1.8\bin\java.exe"
set "APP_JAR=%~dp0Java_proj\idtserver\mrserver\ai\target\ai-1.0-SNAPSHOT.jar"
set "PORT_PID="

for /f "tokens=5" %%P in ('netstat -ano -p tcp ^| findstr /R /C:":83 .*LISTENING"') do set "PORT_PID=%%P"
if defined PORT_PID (
  echo AIModuleServer is already running on port 83.
  echo Process ID: %PORT_PID%
  echo You do not need to start another backend window.
  echo.
  pause
  exit /b 0
)

if not exist "%JAVA_EXE%" (
  set "JAVA_EXE=java"
)

if not exist "%APP_JAR%" (
  echo Backend package was not found:
  echo %APP_JAR%
  echo.
  echo Run Maven package in IDEA first, then start this file again.
  pause
  exit /b 1
)

echo Starting AIModuleServer on http://localhost:83
echo Keep this window open while using the application.
echo The first startup can take about 80 seconds.
echo.

"%JAVA_EXE%" -Xms128m -Xmx512m -jar "%APP_JAR%"

echo.
echo AIModuleServer has stopped. Review the error above before closing this window.
pause
