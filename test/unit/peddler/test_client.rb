# frozen_string_literal: true

require 'helper'
require 'null_client'
require 'webmock/minitest'

class TestPeddlerClient < MiniTest::Test
  def setup
    @klass = Class.new(Null::Client)
    @client = @klass.new
    @client.configure_with_mock_data!
    @client.operation('Foo')
  end

  class HappyPath < TestPeddlerClient
    def setup
      @response_body = 'foo'
      stub_request(:post, /amazonservices/)
        .to_return(body: @response_body, status: 200)
      super
    end

    def test_user_agent
      assert @client.connection.default_options.headers['User-Agent']
    end

    def test_inheritance_of_parents_params
      assert_equal Peddler::Client.params, @klass.params
    end

    def test_that_params_include_seller_id
      assert @klass.params.key?('SellerId')
    end

    def test_that_params_include_auth_token
      @klass.params.key?('MWSAuthToken')
    end

    def test_inheritance_of_parents_parser
      assert_equal @klass.parser, Class.new(@klass).parser
    end

    def test_setting_marketplace
      marketplace = Peddler::Marketplace.find('US')
      @client.marketplace = 'US'
      assert_equal marketplace, @client.marketplace
      @client.marketplace = marketplace
      assert_equal marketplace, @client.marketplace
    end

    def test_configuring_when_initialising
      client = @klass.new(aws_access_key_id: '123')
      assert_equal '123', client.aws_access_key_id
    end

    def test_setting_content_type_header_for_latin_flat_file
      @client.body = 'foo'
      content_type = @client.headers.fetch('Content-Type')

      assert_equal 'text/tab-separated-values; charset=CP1252', content_type
    end

    def test_setting_content_type_header_for_japanese_flat_file
      @client.marketplace = 'JP'
      @client.body = 'foo'
      content_type = @client.headers.fetch('Content-Type')

      assert_equal 'text/tab-separated-values; charset=Windows-31J', content_type
    end

    def test_setting_content_type_header_for_xml
      @client.body = '<?xml version="1.0"?><Foo></Foo>'
      content_type = @client.headers.fetch('Content-Type')

      assert_equal 'text/xml', content_type
    end

    def test_encoding_body_for_latin_flat_file
      @client.body = 'foo'
      assert_equal 'Windows-1252', @client.body.encoding.to_s
    end

    def test_encoding_body_for_japanese_flat_file
      @client.marketplace = 'JP'
      @client.body = 'foo'
      assert_equal 'Windows-31J', @client.body.encoding.to_s
    end

    def test_running_a_request
      res = @client.run
      assert_equal @response_body, res.body.to_s
    end

    def test_clearing_body_when_run_succeeds
      @client.body = 'foo'
      @client.run
      assert_nil @client.body
    end

    def test_streaming_response
      chunks = ''
      streamer = ->(chunk, _, _) { chunks += chunk }
      @client.run(&streamer)

      assert_equal @response_body, chunks
    end
  end

  class MWSErrorPath < TestPeddlerClient
    def setup
      body = <<-XML
        <ErrorResponse>
          <Error>
            <Code>RequestThrottled</Code>
          </Error>
        </ErrorResponse>
      XML
      stub_request(:post, /amazonservices/)
        .to_return(headers: { 'Content-Type' => 'text/xml' }, body: body, status: 503)
      super
    end

    def test_default_error_handling
      assert_raises Peddler::Errors::RequestThrottled do
        @client.run
      end
    end

    def test_it_does_not_clear_body_when_run_fails
      @client.body = 'foo'
      assert_raises Peddler::Errors::RequestThrottled do
        @client.run
      end
      refute_nil @client.body
    end
  end

  class OtherHTTPStatusErrorPath < TestPeddlerClient
    def setup
      body = <<-XML
        <ErrorResponse>
          <Error>
            <Code>500</Code>
          </Error>
        </ErrorResponse>
      XML
      stub_request(:post, /amazonservices/)
        .to_return(headers: { 'Content-Type' => 'text/xml' }, body: body, status: 500)
      super
    end

    def test_error_handling
      # doesn't raise anymore
      @client.run
    end

    def test_it_does_not_clear_body_when_run_fails
      @client.body = 'foo'
      @client.run
      refute_nil @client.body
    end
  end
end
