@echo off
echo ================================================
echo  PropAdmin - Allow Port 5000 Through Firewall
echo ================================================
echo.

netsh advfirewall firewall delete rule name="PropAdmin Backend Port 5000" >nul 2>&1
netsh advfirewall firewall delete rule name="PropAdmin Backend Port 5000 Out" >nul 2>&1

netsh advfirewall firewall add rule name="PropAdmin Backend Port 5000" dir=in action=allow protocol=TCP localport=5000
netsh advfirewall firewall add rule name="PropAdmin Backend Port 5000 Out" dir=out action=allow protocol=TCP localport=5000

echo.
echo ================================================
echo  Done! Port 5000 is now open.
echo  Your Tecno phone can now reach the backend.
echo ================================================
pause
