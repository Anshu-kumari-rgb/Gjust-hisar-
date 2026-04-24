@echo off
setlocal EnableExtensions

if defined NB_DEBUG echo on

cd /d "%~dp0."

echo ===============================
echo   Nation Builder - One Click
echo ===============================
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Node.js not found in PATH. Install Node.js and try again.
  pause
  exit /b 1
)

where npm >nul 2>nul
if errorlevel 1 (
  echo [ERROR] npm not found in PATH. Reinstall Node.js and try again.
  pause
  exit /b 1
)

REM Install deps if needed (covers mysql2 etc.)
if not exist "node_modules" (
  echo Installing dependencies...
  call npm install
  if errorlevel 1 (
    echo [ERROR] npm install failed.
    pause
    exit /b 1
  )
)

REM If something is already listening on 3000, don't spawn another server
set "NB_PORT_BUSY="
for /f "tokens=5" %%P in ('netstat -ano ^| findstr :3000 ^| findstr LISTENING') do (
  set "NB_PORT_BUSY=1"
  set "NB_PID=%%P"
  goto :port_checked
)
:port_checked

if defined NB_PORT_BUSY (
  echo Port 3000 is already in use. PID %NB_PID%. Opening the app...
) else (
  echo Starting backend. It also serves the frontend...
  start "Nation Builder Backend" cmd /k "cd /d ""%~dp0."" && node server.js"
  timeout /t 2 /nobreak >nul
)

echo Opening Nation Builder...
start "" "http://localhost:3000/"

endlocal
