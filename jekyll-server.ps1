# Jekyll Server Startup Script
# This ensures a clean environment

# Clear any existing RUBYOPT
$env:RUBYOPT = $null

# Change to project directory
Set-Location $PSScriptRoot

Write-Host "Starting Jekyll server..." -ForegroundColor Green
Write-Host "NOTE: First build may take 30-60 seconds. Please wait..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Once you see 'Server running', open: http://localhost:4000" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Use bundle exec with explicit environment
& bundle exec jekyll serve -l -H localhost --incremental






