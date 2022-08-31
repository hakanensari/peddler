# frozen_string_literal: true

require 'old_helper'
require 'peddler/errors/parser'

class TestPeddlerErrorsParser < MiniTest::Test
  def setup
    body = <<-XML
      <ErrorResponse>
        <Error>
          <Type>Foo</Type>
          <Code>Bar</Code>
          <Message>Baz</Message>
        </Error>
        <RequestID>123</RequestID>
      </ErrorResponse>
    XML
    res = OpenStruct.new(
      body: body,
      headers: {
        'Content-Type' => 'text/xml',
        'Content-Length' => body.size.to_s
      }
    )

    @parser = Peddler::Errors::Parser.new(res)
  end

  def test_parsing_data
    assert @parser.parse
  end

  def test_message
    assert @parser.message
  end

  def test_code
    assert @parser.code
  end

  def test_type
    assert @parser.type
  end
end
