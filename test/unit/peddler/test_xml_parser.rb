# frozen_string_literal: true

require 'old_helper'
require 'peddler/xml_parser'

class TestPeddlerXMLParser < MiniTest::Test
  Parser = Class.new(::Peddler::XMLParser)

  def setup
    body = '<Foo>Bar</Foo>'

    res = OpenStruct.new(
      body: body,
      headers: {
        'Content-Type' => 'text/xml',
        'Content-Length' => body.size.to_s
      }
    )

    @parser = Parser.new(res)
  end

  def test_that_it_does_not_implement_parsing
    assert_raises(NotImplementedError) do
      @parser.parse
    end
  end

  def test_digging_data
    @parser.instance_variable_set :@data, foo: { bar: :baz }
    assert_equal :baz, @parser.dig(:foo, :bar)
  end

  def test_validation
    assert_predicate @parser, :valid?
  end
end
