# frozen_string_literal: true

require 'old_helper'
require 'peddler/errors/error'

class TestPeddlerErrorsError < MiniTest::Test
  def setup
    @cause = OpenStruct.new(response: 'response')
    @error = Peddler::Errors::Error.new('message', @cause)
  end

  def test_message
    assert_equal 'message', @error.message
  end

  def test_cause
    assert_equal @cause, @error.cause
  end

  def test_that_it_defines_common_errors
    Peddler::Errors::CODES.each do |name|
      assert ::Peddler::Errors.const_defined?(name)
    end
  end

  def test_that_it_allows_nil_arguments
    Peddler::Errors::Error.new
  end

  def test_that_it_delegates_response_to_cause
    assert_equal @cause.response, @error.response
  end
end
