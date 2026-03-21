@echo off
REM This starts a completely fresh CMD window to avoid gem conflicts
REM Uses bundle exec to ensure Jekyll 3.10.0 (matches GitHub Pages)
echo Starting Jekyll in a fresh environment...
echo This will use Jekyll 3.10.0 to match GitHub Pages exactly.
echo.
start cmd /k "cd /d %~dp0 && bundle exec ruby -rtzinfo -rtzinfo/data -S jekyll serve -l -H localhost --incremental"


