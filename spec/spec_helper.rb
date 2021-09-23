# frozen_string_literal: true

require 'replayer'
require 'tmpdir'
#require 'vcr'

include RSpec

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

Replayer.configure do |config|
  cassette_folder = Dir.mktmpdir('/tmp')
  config.cassette_folder = cassette_folder
  at_exit { FileUtils.remove_entry(cassette_folder) } if ENV['KEEP_CASSETTES'].nil?
end

#VCR.configure do |config|
  #config.cassette_library_dir='fixtures/vcr'
  #  config.hook_into :webmock
#end