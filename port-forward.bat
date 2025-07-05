@echo off
setlocal enabledelayedexpansion

:: Vérifier les privilèges administrateur
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Ce script necessite des privileges administrateur.
    echo [INFO] Relancement en tant qu'administrateur...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Vérifier si la redirection existe déjà
netsh interface portproxy show all | findstr "5001" >nul 2>&1
if %errorlevel% equ 0 (
    netsh interface portproxy reset
    echo [INFO] Redirection de port OFF
) else (
    netsh interface portproxy add v4tov4 listenport=5001 listenaddress=0.0.0.0 connectport=5001 connectaddress=172.20.163.185
    netsh advfirewall firewall add rule name="Flask API" dir=in action=allow protocol=TCP localport=5001
    echo [INFO] Redirection de port ON
    echo [INFO] API accessible sur: http://172.20.163.185:5001
)

echo.
echo [INFO] Appuyez sur une touche pour fermer...
pause >nul 