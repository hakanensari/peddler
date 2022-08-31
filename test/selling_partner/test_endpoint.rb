# frozen_string_literal: true

require 'helper'
require 'selling_partner/endpoint'

module SellingPartner
  class TestEndpoint < MiniTest::Test
    def test_find_bang
      assert_raises Endpoint::NotFound do
        Endpoint.find!('foo')
      end
    end

    def test_uri
      endpoint = Endpoint.find('us-east-1')
      assert endpoint.uri
    end

    def test_sandbox_uri
      endpoint = Endpoint.find('us-east-1')
      assert endpoint.sandbox_uri
    end
  end
end
