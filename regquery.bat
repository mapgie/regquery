@REM # ******************************************************************************************
@REM #|      mapgiedev
@REM #|      ------------------------------------------------
@REM #|      PROGRAM NAME : regquery.bat
@REM #|      CREATE DATE  : 13/01/2021
@REM #|      AUTHOR       : mapgie
@REM #|      FUNCTION     : The Windows Registry Editor doesn't have a quick ID search. This bat file
@REM #|                     allows you to paste an ID and find out if there is a match in your registry.
@REM #|
@REM # ******************************************************************************************
@REM #	HISTORY
@REM #  1.00 - 13/01/2021 - mapgie: Created
@REM # ******************************************************************************************
@echo off

:metadata
cd /d %userprofile%
set startDP=%~dp0

set JOB=%~n0
set TITLE=Query Registry

:files
SET basedir=%startDP%
SET logdir=%basedir%Logs\ 
if not exist %logdir%NUL mkdir %logdir%

SET LOG="%logdir%%JOB%.txt"
if not exist %LOG% (echo. > %LOG%)
(echo.
echo user:	%USERNAME% ran %~nx0 in %startDP% on %date%; 
echo started:	%time%) >> %log%

SET ERRTXT="%logdir%%JOB%_error.txt"
SET ERRFIL="%logdir%%JOB%_errorList.txt"
SET BATCHLOG="%logdir%%JOB%_outputlog.txt"
IF EXIST %ERRTXT% DEL %ERRTXT%
IF EXIST %ERRFIL% DEL %ERRFIL%
IF EXIST %BATCHLOG% DEL %BATCHLOG%

echo. > %ERRTXT%
echo. > %ERRFIL%
echo. > %BATCHLOG%

:sectionMarkers
SET /a major=0
SET /a minor=0

:start
echo example ID: S-1-5-21-3887888887-2328133166-2392687879-1001
set /p ID="ID to query: "

:query
echo Search Registry for: %ID% 
echo Looking in...

:ClassesRoot
set stageName=HKEY_CLASSES_ROOT
call :Major

set stageName=HKEY_CLASSES_ROOT\
call :Minor

set stageName=HKEY_CLASSES_ROOT\AppID
call :Minor

set stageName=HKEY_CLASSES_ROOT\Record
call :Minor

:LocalMachine
set stageName=HKEY_LOCAL_MACHINE
call :Major

set stageName=HKEY_LOCAL_MACHINE\SOFTWARE\Classes\AppID
call :Minor

:Users
set stageName=HKEY_USERS
call :Major
call :Minor

:endLog
(echo ended:		%time%) >> %log%

:openFolder
REM opens folder
REM echo %SystemRoot%\explorer.exe "" "%newFolder%"
echo %ID% Results Log: Opening...
rem %SystemRoot%\explorer.exe "%startDP%"
%SystemRoot%\explorer.exe "%batchlog%"

:EOF
echo End of File
pause
exit


rem ::: SUB ROUTINES :::

:Major
set /a major=major+1
set /a minor=0
call :logtime
exit /b

:Minor
set /a minor=minor+1
call :logtime

set query=reg query "%stageName%\{%ID%}" /ve /S

%query%

(%query%) >>%BATCHLOG%
call :ResetError
exit /b

:ResetError
if %errorlevel% gtr 0 (echo 			No default values found in Registry for given key. 
echo.)>>%BATCHLOG%
cmd /c "exit /b 0"
rem (echo clearing errors: %errorlevel%)>>%BATCHLOG%
exit /b

:logtime
set stage=%major%.%minor%
echo %stage%: %stageName%
if %minor% equ 0 (echo %stage%: %stageName%) >> %BATCHLOG%
if %minor% gtr 0 (echo %time%	%stage%: %stageName%) >> %BATCHLOG%
exit /b
