#!/usr/bin/env ruby
# Wrapper script to bypass timezone issues on Windows
require 'bundler/setup'

# Patch Jekyll's timezone handling BEFORE loading Jekyll
# This prevents the TZInfo::DataSourceNotFound error
module Jekyll
  module Utils
    module WinTZ
      def self.calculate(*args)
        # Return UTC directly instead of trying to detect timezone
        'UTC'
      end
    end
  end
end

# Also patch TZInfo to avoid data source errors
require 'tzinfo'
module TZInfo
  class DataSource
    class << self
      alias_method :original_get, :get
      def get
        # Return a mock data source that just uses UTC
        @mock_ds ||= begin
          # Try to create a real one first
          begin
            require 'tzinfo/data'
            TZInfo::DataSources::RubyDataSource.new
          rescue LoadError
            # Create a minimal mock that just returns UTC
            Object.new.tap do |ds|
              def ds.get_timezone(identifier)
                TZInfo::Timezone.get('UTC')
              end
            end
          end
        end
      end
    end
  end
end

# Load Jekyll
load Gem.bin_path('jekyll', 'jekyll', '>= 0.a')
