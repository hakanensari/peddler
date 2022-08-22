# frozen_string_literal: true

require 'integration_helper'
require 'mws/orders'

class TestErrors < IntegrationTest
  use 'Orders'

  def test_invalid_key
    clients.each do |client|
      client.aws_access_key_id = 'foo'
      assert_raises Peddler::Errors::InvalidAccessKeyId do
        client.get_order('bar')
      end
    end
  end
end
