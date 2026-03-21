# Load tzinfo-data for Windows before Jekyll starts
begin
  require 'tzinfo/data'
rescue LoadError
  # If tzinfo-data is not available, continue without it
  # Jekyll will handle the timezone differently
end





