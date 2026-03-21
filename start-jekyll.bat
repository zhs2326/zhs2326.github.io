@echo off
echo Starting Jekyll server...
echo.
echo NOTE: First build may take 30-60 seconds. Please wait...
echo Once you see "Server running", open: http://localhost:4000
echo Press Ctrl+C to stop the server
echo.

REM Don't set RUBYOPT before bundle exec - it causes gem conflicts
REM Instead, use bundle exec with ruby -r flags
bundle exec ruby -rtzinfo -rtzinfo/data -S jekyll serve -l -H localhost --incremental

