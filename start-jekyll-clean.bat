@echo off
REM Clean startup script that avoids gem conflicts
echo Starting Jekyll server...
echo.
echo NOTE: First build may take 30-60 seconds. Please wait...
echo Once you see "Server running", open: http://localhost:4000
echo Press Ctrl+C to stop the server
echo.

REM Use cmd /c to start fresh shell and avoid gem conflicts
cmd /c "set RUBYOPT=-rtzinfo -rtzinfo/data && cd /d %~dp0 && bundle exec jekyll serve -l -H localhost --incremental"






