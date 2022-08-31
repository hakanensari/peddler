# frozen_string_literal: true

require 'old_helper'
require 'null_client'
require 'peddler/vcr_matcher'
require 'recorder'

class TestPeddlerVCRMatcher < MiniTest::Test
  include Recorder
  ::Peddler::VCRMatcher.ignore_seller!

  def setup
    VCR.insert_cassette(test_name, record: :none)
  end

  def test_matching_recorded_post_without_body
    client.run
  end

  def test_wont_match_unrecorded_post_without_body
    client.operation.add(foo: 'bar')
    assert_raises(VCR::Errors::UnhandledHTTPRequestError) do
      client.run
    end
  end

  def test_matching_recorded_post_with_body
    client.body = 'content'
    client.run
  end

  def test_that_it_wont_match_unrecorded_post_with_different_query_and_same_body
    client.operation.add(foo: 'bar')
    client.body = 'content'
    assert_raises(VCR::Errors::UnhandledHTTPRequestError) do
      client.run
    end
  end

  def test_that_it_wont_match_unrecorded_post_with_same_query_and_different_body
    client.body = 'other content'
    assert_raises(VCR::Errors::UnhandledHTTPRequestError) do
      client.run
    end
  end

  def client
    @client ||= begin
      client = Class.new(Null::Client).new
      client.configure_with_mock_data!
      client.operation('Action')
      client
    end
  end
end
