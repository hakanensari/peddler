# frozen_string_literal: true

require 'old_helper'
require 'mws/orders/client'

class TestMWSOrdersClient < MiniTest::Test
  def setup
    @client = MWS::Orders::Client.new
  end

  def test_listing_orders
    operation = {
      'Action' => 'ListOrders',
      'CreatedAfter' => '2016-01-01',
      'OrderStatus.Status.1' => '1',
      'MarketplaceId.Id.1' => '123',
      'PaymentMethod.1' => '1',
      'TFMShipmentStatus.Status.1' => '1',
      'FulfillmentChannel.Channel.1' => 'MFN'
    }

    @client.stub(:run, nil) do
      @client.list_orders(
        '123',
        created_after: '2016-01-01',
        order_status: '1',
        tfm_shipment_status: '1',
        payment_method: '1',
        fulfillment_channel: 'MFN'
      )
    end

    assert_equal operation, @client.operation
  end

  def test_that_listing_orders_requires_start_time_keyword
    @client.stub(:run, nil) do
      error = assert_raises ArgumentError do
        @client.list_orders('123')
      end
      assert_equal 'specify created_after or last_updated_after', error.message
      @client.list_orders('123', created_after: '2016-01-01')
      @client.list_orders('123', last_updated_after: '2016-01-01')
    end
  end

  def test_listing_orders_by_next_token
    operation = {
      'Action' => 'ListOrdersByNextToken',
      'NextToken' => '1'
    }

    @client.stub(:run, nil) do
      @client.list_orders_by_next_token('1')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_order
    operation = {
      'Action' => 'GetOrder',
      'AmazonOrderId.Id.1' => '1',
      'AmazonOrderId.Id.2' => '2'
    }

    @client.stub(:run, nil) do
      @client.get_order('1', '2')
    end

    assert_equal operation, @client.operation
  end

  def test_listing_order_items
    operation = {
      'Action' => 'ListOrderItems',
      'AmazonOrderId' => '1'
    }

    @client.stub(:run, nil) do
      @client.list_order_items('1')
    end

    assert_equal operation, @client.operation
  end

  def test_listing_order_items_by_next_token
    operation = {
      'Action' => 'ListOrderItemsByNextToken',
      'NextToken' => '1'
    }

    @client.stub(:run, nil) do
      @client.list_order_items_by_next_token('1')
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
