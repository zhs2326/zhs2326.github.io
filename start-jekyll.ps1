# Start Jekyll with tzinfo-data support on Windows
$env:RUBYOPT = "-rtzinfo -rtzinfo/data"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
bundle exec jekyll serve -l -H localhost

