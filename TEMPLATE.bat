::           Bitpusher
::            \`._,'/
::            (_- -_)
::              \o/
::          The Digital
::              Fox
::          @VinceVulpes
::    https://theTechRelay.com
:: https://github.com/bitpusher2k
::
:: TEMPLATE.bat - By Bitpusher/The Digital Fox
:: v1.0 last updated 2023-00-00
:: Script to XXXX 
:: XXXX
::
:: To undo: XXXX
::
:: A set of basic templates for BAT/PS scripts to facilitate good practices
:: when scripting for scheduled tasks and automation across many endpoints.
:: When running scripts in a way that the execution is not being monitored
:: there are several factors which become much more important:
::
:: 1. Documentation - Standardized information and instructions at 
::      the beginning of the script (name, version, date, how to).
:: 2. Logging - Central log location & basic log management. Including of
::      endpoint name in log name. Option to email log file or copy to 
::      shared folder. Uses PS transcript for accuracy and verbosity of log.
:: 3. Date stamps - Date stamps included in log name and in the log files
::      themselves, including ISO8601-formatted version.
:: 4. Process priority - Includes option to set script priority 
::      (for scripts that are resource intensive).
:: 5. Timing of execution - Includes option to add random delay to script
::      execution (for staggering execution when running across many endpoints).
:: 6. Error handling - Catches basic errors, and set up to return exit status.
::
:: This BAT template lacks some of these features - Can not email or copy log file,
:: can not set process priority - and is to be used when PowerShell is not an option.
::
:: Be sure to update your log folder location and script name
::
:: Run with admin privileges
::
:: #template #script #bat

::@echo off ::Turn off all command echo here - left on for more verbose logging of main script body
cls
@color 06
@set ScriptName=TEMPLATE
@set LogFolder=C:\Utility\log\
@set /a rand=%random% %%495+5
@break on
@title %ScriptName%.bat - By Bitpusher/The Digital Fox
@setlocal EnableDelayedExpansion
:: Get timestamp
:: Check WMIC is available
WMIC.EXE Alias /? >NUL 2>&1 || GOTO s_error

:: Use WMIC to retrieve date and time
@for /F "skip=1 tokens=1-6" %%G IN ('WMIC Path Win32_LocalTime Get Day^,Hour^,Minute^,Month^,Second^,Year /Format:table') do (
  @if "%%~L"=="" goto s_done
  @set _yyyy=%%L
  @set _mm=00%%J
  @set _dd=00%%G
  @set _hour=00%%H
  @set _minute=00%%I
  @set _second=00%%K
)
:s_done
:: Pad digits with leading zeros
@set _mm=%_mm:~-2%
@set _dd=%_dd:~-2%
@set _hour=%_hour:~-2%
@set _minute=%_minute:~-2%
@set _second=%_second:~-2%
@set mytimestamp=%_yyyy%%_mm%%_dd%_%_hour%%_minute%%_second%

:: get UTC times:
@for /f %%a in ('wmic Path Win32_UTCTime get Year^,Month^,Day^,Hour^,Minute^,Second /Format:List ^| findstr "="') do (set %%a)
@set Second=0%Second%
@set Second=%Second:~-2%
@set Minute=0%Minute%
@set Minute=%Minute:~-2%
@set Hour=0%Hour%
@set Hour=%Hour:~-2%
@set Day=0%Day%
@set Day=%Day:~-2%
@set Month=0%Month%
@set Month=%Month:~-2%
@set UTCTIME=%Hour%%Minute%%Second%
@set UTCDATE=%Year%%Month%%Day%
@set UTCDATESTAMP=%UTCDATE%%UTCTIME%.00Z

@cls
@echo.
@if not exist %LogFolder% (
  @mkdir %LogFolder%
  @if "!errorlevel!" EQU "0" (
    @echo Log folder created successfully
  ) else (
    @echo Error while creating log folder
  )
) else (
  @echo Log folder already exists
)

@goto main
:s_error
@echo.
@echo WMIC is not available, using default log filename
@set mydate=%date:/=%
@set mytime=%time::=%
@set mytimestamp=%mydate: =_%_%mytime:.=_%
@set UTCDATESTAMP=unavailable

:main
@echo.
@echo logging output to %LogFolder%%ScriptName%-%computername%-%mytimestamp%.log
@echo script will wait %rand% seconds before main body execution to stagger start across devices
@echo.
@call :transcribe > %LogFolder%%ScriptName%-%computername%-%mytimestamp%.log 2>&1
@type %LogFolder%%ScriptName%-%computername%-%mytimestamp%.log
::@color 0f
@exit /b %errorlevel%

:transcribe
@echo Starting %ScriptName%.bat at %mytimestamp% local time...
@echo ISO8601:%UTCDATESTAMP%
@echo.
@echo Waiting %rand% seconds to stagger execution start across devices
timeout /t %rand%

:: To force an ERRORLEVEL of 1 to be set without exiting 
:: run a small but invalid command like COLOR 00 or run (CALL) 
:: which does nothing other than set the ERRORLEVEL to 1. 
:: To clear the ERRORLEVEL back to 0, run (call ), which does 
:: nothing except set the ERRORLEVEL to 0.
:: exit /b %errorlevel%
@(call)

::
:: TODO: Replace this block with your actual script body:
@echo.
@echo Example output message.
:: End main script body
:: Remember to update $scriptName parameter
::

:: Reset ERRORLEVEL to 0
@(call )
@echo Errorlevel after script execution: %errorlevel%
@exit /b %errorlevel%

:end
