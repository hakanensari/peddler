# frozen_string_literal: true

require 'old_helper'
require 'mws/fulfillment_outbound_shipment/client'

class TestMWSFulfillmentOutboundShipmentClient < MiniTest::Test
  def setup
    @client = MWS::FulfillmentOutboundShipment::Client.new
  end

  def test_getting_fulfillment_preview
    operation = {
      'Action' => 'GetFulfillmentPreview',
      'Address.Foo' => '1',
      'Items.member.1.Bar' => '2',
      'ShippingSpeedCategories.member.1' => '3',
      'IncludeCODFulfillmentPreview' => true
    }

    @client.stub(:run, nil) do
      @client.get_fulfillment_preview(
        { 'Foo' => '1' },
        [{ 'Bar' => '2' }],
        shipping_speed_categories: ['3'],
        include_cod_fulfillment_preview: true
      )
    end

    assert_equal operation, @client.operation
  end

  def test_creating_fulfillment_order
    operation = {
      'Action' => 'CreateFulfillmentOrder',
      'SellerFulfillmentOrderId' => '1',
      'DisplayableOrderId' => '2',
      'DisplayableOrderDateTime' => '3',
      'DisplayableOrderComment' => '4',
      'ShippingSpeedCategory' => '5',
      'DestinationAddress.Foo' => '1',
      'Items.member.1.Bar' => '2',
      'CODSettings.Foo' => '1',
      'NotificationEmailList.member.1' => '1'
    }

    @client.stub(:run, nil) do
      @client.create_fulfillment_order(
        '1', '2', '3', '4', '5',
        { 'Foo' => '1' },
        [{ 'Bar' => '2' }],
        cod_settings: { 'Foo' => '1' },
        notification_email_list: ['1']
      )
    end

    assert_equal operation, @client.operation
  end

  def test_updating_fulfillment_order
    operation = {
      'Action' => 'UpdateFulfillmentOrder',
      'SellerFulfillmentOrderId' => '1',
      'Items.member.1.Bar' => '2',
      'NotificationEmailList.member.1' => '1'
    }

    @client.stub(:run, nil) do
      @client.update_fulfillment_order(
        '1',
        items: [{ 'Bar' => '2' }],
        notification_email_list: ['1']
      )
    end

    assert_equal operation, @client.operation
  end

  def test_getting_fulfillment_order
    operation = {
      'Action' => 'GetFulfillmentOrder',
      'SellerFulfillmentOrderId' => '1'
    }

    @client.stub(:run, nil) do
      @client.get_fulfillment_order('1')
    end

    assert_equal operation, @client.operation
  end

  def test_listing_all_fulfillment_orders
    started_at = Time.now

    operation = {
      'Action' => 'ListAllFulfillmentOrders',
      'QueryStartDateTime' => started_at.utc.iso8601(2)
    }

    @client.stub(:run, nil) do
      @client.list_all_fulfillment_orders(query_start_date_time: started_at)
    end

    assert_equal operation, @client.operation
  end

  def test_listing_all_fulfillment_orders_by_next_token
    operation = {
      'Action' => 'ListAllFulfillmentOrdersByNextToken',
      'NextToken' => '1'
    }

    @client.stub(:run, nil) do
      @client.list_all_fulfillment_orders_by_next_token('1')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_package_tracking_details
    operation = {
      'Action' => 'GetPackageTrackingDetails',
      'PackageNumber' => '1'
    }

    @client.stub(:run, nil) do
      @client.get_package_tracking_details('1')
    end

    assert_equal operation, @client.operation
  end

  def test_canceling_fulfillment_order
    operation = {
      'Action' => 'CancelFulfillmentOrder',
      'SellerFulfillmentOrderId' => '1'
    }

    @client.stub(:run, nil) do
      @client.cancel_fulfillment_order('1')
    end

    assert_equal operation, @client.operation
  end

  def test_listing_return_reason_codes
    seller_sku = 'ABC123'
    seller_fulfillment_order_id = '123ABC'

    operation = {
      'Action' => 'ListReturnReasonCodes',
      'SellerSKU' => seller_sku,
      'SellerFulfillmentOrderId' => seller_fulfillment_order_id
    }

    @client.stub(:run, nil) do
      @client.list_return_reason_codes(
        seller_sku,
        seller_fulfillment_order_id: seller_fulfillment_order_id
      )
    end

    assert_equal operation, @client.operation
  end

  def test_creating_fulfillment_return
    seller_fulfillment_order_id = 'ABC123'

    item = { seller_return_item_id: 'ABC123',
             seller_fulfillment_order_item_id: 'ABC123',
             amazon_shipment_id: 'ABC123',
             return_reason_code: 'VALID_RETURN_REASON_CODE',
             return_comment: 'RETURN COMMENT FROM CLIENT' }

    operation = {
      'Action' => 'CreateFulfillmentReturn',
      'SellerFulfillmentOrderId' => seller_fulfillment_order_id,
      'Items.member.1.SellerReturnItemId' => item[:seller_return_item_id],
      'Items.member.1.SellerFulfillmentOrderItemId' => item[:seller_fulfillment_order_item_id],
      'Items.member.1.AmazonShipmentId' => item[:amazon_shipment_id],
      'Items.member.1.ReturnReasonCode' => item[:return_reason_code],
      'Items.member.1.ReturnComment' => item[:return_comment]
    }

    @client.stub(:run, nil) do
      @client.create_fulfillment_return(seller_fulfillment_order_id, [item])
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
