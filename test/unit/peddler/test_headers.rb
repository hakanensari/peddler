# frozen_string_literal: true

require 'old_helper'
require 'peddler/headers'

class TestPeddlerHeaders < MiniTest::Test
  include ::Peddler::Headers

  attr_reader :headers

  def setup
    @headers = {
      'Content-Length' => '100',
      'Content-MD5' => 'rkkx1Xv/k56/onrN0m7E/Q==',
      'Content-Type' => 'text/plain;charset=UTF-8',
      'x-mws-quota-max' => '200.0',
      'x-mws-quota-remaining' => '200.0',
      'x-mws-quota-resetsOn' => '2017-01-30T00:03:00.000Z',
      'x-mws-request-id' => '123',
      'x-mws-timestamp' => '2017-01-29T23:55:25.356Z',
      'x-mws-response-context' => 'foo'
    }
  end

  def test_content_length
    assert_kind_of Integer, content_length
  end

  def test_content_md5
    assert content_md5
  end

  def test_content_media_type
    assert content_media_type
  end

  def test_content_type
    assert content_type
  end

  def test_content_subtype
    assert content_subtype
  end

  def test_content_charset
    assert_kind_of Encoding, content_charset
  end

  def test_no_content_length
    @headers.delete('Content-Length')
    assert_nil content_length
  end

  def test_no_content_type
    @headers.delete('Content-Type')
    assert_nil content_media_type
    assert_nil content_type
    assert_nil content_subtype
    assert_nil content_charset
  end

  def test_no_content_charset
    @headers['Content-Type'] = 'text/xml'
    assert content_media_type
    assert content_type
    assert content_subtype
    assert_nil content_charset
  end

  def test_utf8_content_charset
    @headers['Content-Type'] = 'text/plain;charset=utf8'
    assert_equal Encoding::UTF_8, content_charset
  end

  def test_mws_quota_max
    assert_kind_of Integer, mws_quota_max
  end

  def test_mws_quota_remaining
    assert_kind_of Integer, mws_quota_remaining
  end

  def test_mws_quota_resets_on
    assert_kind_of Time, mws_quota_resets_on
  end

  def test_request_id
    assert mws_request_id
  end

  def test_timestamp
    assert_kind_of Time, mws_timestamp
  end

  def test_response_context
    assert mws_response_context
  end

  def test_handling_no_quota
    @headers = {}
    assert_nil mws_quota_max
    assert_nil mws_quota_remaining
    assert_nil mws_quota_resets_on
    assert_nil mws_request_id
    assert_nil mws_timestamp
    assert_nil mws_response_context
  end
end
