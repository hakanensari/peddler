# frozen_string_literal: true

require 'old_helper'
require 'mws/merchant_fulfillment/client'

class TestMWSMerchantFulfillmentClient < MiniTest::Test
  def setup
    @client = MWS::MerchantFulfillment::Client.new
  end

  def test_getting_eligible_shipping_services
    operation = {
      'Action' => 'GetEligibleShippingServices',
      'ShipmentRequestDetails.AmazonOrderId' => '123',
      'ShipmentRequestDetails.Weight.Value' => '10',
      'ShipmentRequestDetails.Weight.Unit' => 'ounces',
      'ShipmentRequestDetails.ItemList.Item.1.OrderItemId' => '123',
      'ShipmentRequestDetails.ItemList.Item.1.Quantity' => '1'
    }

    @client.stub(:run, nil) do
      shipment_request_details = {
        amazon_order_id: '123',
        weight: {
          value: '10',
          unit: 'ounces'
        },
        item_list: [
          {
            order_item_id: '123',
            quantity: '1'
          }
        ]
      }
      @client.get_eligible_shipping_services(shipment_request_details)
    end

    assert_equal operation, @client.operation
  end

  def test_creating_shipment
    operation = {
      'Action' => 'CreateShipment',
      'ShipmentRequestDetails.AmazonOrderId' => '123',
      'ShipmentRequestDetails.Weight.Value' => '10',
      'ShipmentRequestDetails.Weight.Unit' => 'ounces',
      'ShipmentRequestDetails.ItemList.Item.1.OrderItemId' => '123',
      'ShipmentRequestDetails.ItemList.Item.1.Quantity' => '1',
      'ShippingServiceId' => 'FOO'
    }

    @client.stub(:run, nil) do
      shipment_request_details = {
        amazon_order_id: '123',
        weight: {
          value: '10',
          unit: 'ounces'
        },
        item_list: [
          {
            order_item_id: '123',
            quantity: '1'
          }
        ]
      }
      @client.create_shipment(shipment_request_details, 'FOO')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_shipment
    operation = {
      'Action' => 'GetShipment',
      'ShipmentId' => '123'
    }

    @client.stub(:run, nil) do
      @client.get_shipment('123')
    end

    assert_equal operation, @client.operation
  end

  def test_canceling_shipment
    operation = {
      'Action' => 'CancelShipment',
      'ShipmentId' => '123'
    }

    @client.stub(:run, nil) do
      @client.cancel_shipment('123')
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
