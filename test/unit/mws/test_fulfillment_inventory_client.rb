# frozen_string_literal: true

require 'old_helper'
require 'mws/fulfillment_inventory/client'

class TestMWSFulfillmentInventoryClient < MiniTest::Test
  def setup
    @client = MWS::FulfillmentInventory::Client.new
  end

  def test_listing_inventory_supply
    operation = {
      'Action' => 'ListInventorySupply',
      'SellerSkus.member.1' => '1'
    }

    @client.stub(:run, nil) do
      @client.list_inventory_supply(seller_skus: '1')
    end

    assert_equal operation, @client.operation
  end

  def test_listing_inventory_supply_by_next_token
    operation = {
      'Action' => 'ListInventorySupplyByNextToken',
      'NextToken' => '1'
    }

    @client.stub(:run, nil) do
      @client.list_inventory_supply_by_next_token('1')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_service_status
    operation = {
      'Action' => 'GetServiceStatus'
    }

    @client.stub(:run, nil) do
      @client.get_service_status
    end

    assert_equal operation, @client.operation
  end
end
