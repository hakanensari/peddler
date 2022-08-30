# frozen_string_literal: true

require 'peddler/vcr_matcher'
require 'yaml'
require 'vcr'

# So we can continue testing against old Content-MD5 header
::Peddler::VCRMatcher.ignored_params << 'ContentMD5Value'

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = 'test/vcr_cassettes'

  c.default_cassette_options = {
    match_requests_on: [::Peddler::VCRMatcher],
    record: ENV['RECORD'] ? :new_episodes : :none
  }

  # c.before_record do |interaction|
  #   code = interaction.response.status.code
  #   interaction.ignore! if code >= 400 && code != 414
  # end
end

module Recorder
  def setup
    ENV['LIVE'] ? VCR.turn_off! : VCR.insert_cassette(test_name)
  end

  def teardown
    VCR.eject_cassette if VCR.turned_on?
  end

  private

  def test_name
    self.class.name.sub('Test', '')
  end
end
