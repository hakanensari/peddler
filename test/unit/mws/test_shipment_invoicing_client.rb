# frozen_string_literal: true

require 'old_helper'
require 'mws/shipment_invoicing/client'

class TestMWSShipmentInvoicingClient < MiniTest::Test
  def setup
    @client = MWS::ShipmentInvoicing::Client.new(marketplace: 'BR')
  end

  def test_getting_fba_outbound_shipment_detail
    operation = { 'Action' => 'GetFBAOutboundShipmentDetail',
                  'MarketplaceId' => '123',
                  'AmazonShipmentId' => '456' }
    @client.stub(:run, nil) do
      @client.get_fba_outbound_shipment_detail('123', '456')
    end

    assert_equal operation, @client.operation
  end

  def test_submitting_fba_outbound_shipment_invoice
    operation = { 'Action' => 'SubmitFBAOutboundShipmentInvoice',
                  'MarketplaceId' => '123',
                  'AmazonShipmentId' => '456' }
    @client.stub(:run, nil) do
      @client.submit_fba_outbound_shipment_invoice('123', '456', 'content')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_fba_outbound_shipment_invoice_status
    operation = { 'Action' => 'GetFBAOutboundShipmentInvoiceStatus',
                  'MarketplaceId' => '123',
                  'AmazonShipmentId' => '456' }
    @client.stub(:run, nil) do
      @client.get_fba_outbound_shipment_invoice_status('123', '456')
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
