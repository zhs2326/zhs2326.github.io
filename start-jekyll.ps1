# Start Jekyll with tzinfo-data support on Windows
# Clear RUBYOPT to avoid gem conflicts
$env:RUBYOPT = ""
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
# Use wrapper script to handle timezone data loading
bundle exec ruby jekyll-wrapper.rb serve -l -H localhost --incremental

