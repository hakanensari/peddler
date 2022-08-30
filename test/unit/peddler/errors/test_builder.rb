# frozen_string_literal: true

require 'helper'
require 'http'
require 'peddler/errors/builder'

class TestPeddlerErrorsBuilder < MiniTest::Test
  def setup
    @error = Peddler::Errors::Builder.call(@cause)
  end

  class CausedByHTTPStatusError < TestPeddlerErrorsBuilder
    def setup
      @code = 'FeedProcessingResultNotReady'
      @message = 'Feed Submission Result is not ready for Feed 123'
      body = <<-XML
        <ErrorResponse>
          <Error>
            <Code>#{@code}</Code>
            <Message>#{@message}</Message>
          </Error>
        </ErrorResponse>
      XML
      opts = {
        status: 404,
        body: body,
        version: '1.1',
        request: HTTP::Request.new(uri: 'https://example.com', verb: :get)
      }
      @cause = HTTP::Response.new(opts)
      super
    end

    def test_custom_error
      assert_includes @error.class.name, @code
    end

    def test_message
      assert_equal @message, @error.message
    end

    def test_cause
      assert_equal @cause, @error.cause
    end
  end

  class CausedByInternalServerError < TestPeddlerErrorsBuilder
    def setup
      body = <<-XML
        <ErrorResponse>
          <Error>
            <Code>500</Code>
          </Error>
        </ErrorResponse>
      XML
      opts = {
        status: 500,
        body: body,
        version: '1.1',
        request: HTTP::Request.new(uri: 'https://example.com', verb: :get)
      }
      @cause = HTTP::Response.new(opts)
      super
    end

    def test_that_it_returns_nothing
      assert_nil @error
    end
  end

  class CausedByErrorWithNoErrorResponse < TestPeddlerErrorsBuilder
    def setup
      opts = {
        status: 500,
        body: nil,
        version: '1.1',
        request: HTTP::Request.new(uri: 'https://example.com', verb: :get)
      }
      @cause = HTTP::Response.new(opts)
      super
    end

    def test_that_it_returns_nothing
      assert_nil @error
    end
  end

  # https://github.com/hakanensari/peddler/issues/145
  class Issue145 < TestPeddlerErrorsBuilder
    def setup
      Peddler::Errors.const_set(:InvalidMarketplace, StandardError)
      body = <<-XML
        <ErrorResponse>
          <Error>
            <Code>InvalidMarketplace</Code>
            <Message>Feed rejected</Message>
          </Error>
        </ErrorResponse>
      XML
      opts = {
        status: 500,
        body: body,
        version: '1.1',
        request: HTTP::Request.new(uri: 'https://example.com', verb: :get)
      }
      @cause = HTTP::Response.new(opts)
    end

    def test_throws_type_error
      assert_raises TypeError do
        Peddler::Errors::Builder.call(@cause)
      end
    end
  end
end
