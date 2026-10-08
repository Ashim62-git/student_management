@echo off
rem Runs the app-bundled Postman CLI on the desktop app's own Electron binary.
rem
rem goto, not ( ) blocks: cmd parses a block whole, so a ')' in a path breaks it.

setlocal
set "BIN_DIR=%~dp0"
for %%I in ("%BIN_DIR%..") do set "ROOT=%%~fI"
set "BUNDLE=%ROOT%\postman.bundled.js"

rem `if defined`, not a string compare: cmd substitutes the value before parsing
rem the line, so a quote in it would escape the literal.
if not exist "%BUNDLE%" goto :nobundle
if not defined POSTMAN_CLI_ELECTRON goto :noelectron

set "ELECTRON_RUN_AS_NODE=1"
set "POSTMAN_CLI_BUNDLED_ROOT=%ROOT%"

rem Electron reads the OS trust store, Node does not, so the app's CA setting has to
rem be handed over explicitly. `setlocal` keeps it to this process.
if defined POSTMAN_CLI_CA_CERTS set "NODE_EXTRA_CA_CERTS=%POSTMAN_CLI_CA_CERTS%"
"%POSTMAN_CLI_ELECTRON%" "%BUNDLE%" %*
exit /b %ERRORLEVEL%

:nobundle
>&2 echo postman: bundled CLI not found at "%BUNDLE%"
exit /b 1

:noelectron
>&2 echo postman: POSTMAN_CLI_ELECTRON is not set - the app-bundled CLI only runs in Postman's terminal.
exit /b 1
