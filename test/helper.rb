# frozen_string_literal: true

# Keep SimpleCov at top.
if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start do
    add_filter '/test/'
  end
end

require 'minitest/autorun'
require 'minitest/focus'
require 'vcr'

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = 'test/vcr_cassettes'

  c.default_cassette_options = {
    record: ENV['RECORD'] ? :new_episodes : :none
  }
end

class IntegrationTest < MiniTest::Test
  def setup
    ENV['LIVE'] ? VCR.turn_off! : VCR.insert_cassette(cassette_name)
  end

  def teardown
    VCR.eject_cassette if VCR.turned_on?
  end

  private

  def cassette_name
    File.basename($PROGRAM_NAME, '.*').sub('test_', '')
  end
end
