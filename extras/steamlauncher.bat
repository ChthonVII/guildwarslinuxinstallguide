echo off
REM echo on
REM echo "Let's go!"

cd /D "C:\Program Files (x86)\uMod"
start uMod.exe

REM echo "sleeping 2 sec"
ping -n 3 127.0.0.1 > nul
REM need to symlink GW directory so that it exists here in the prefix
cd ..
cd "Guild Wars"
start Gw.exe

REM echo "sleeping 5 sec"
ping -n 5 127.0.0.1 > nul
cd ..
cd GWToolbox
REM start GWToolbox.exe
start GWToolbox.exe /quiet

REM echo "sleeping 30 sec"
REM ping -n 31 127.0.0.1 > nul
REM echo "All done!"
