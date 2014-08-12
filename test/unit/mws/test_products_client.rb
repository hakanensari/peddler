require 'test_helper'
require 'mws/products/client'

class TestProductsClient < MiniTest::Test
  def test_operation_includes_marketplace_id
    client = MWS::Products::Client.new
    assert client.operation('Foo').has_key?('MarketplaceId')
  end
end