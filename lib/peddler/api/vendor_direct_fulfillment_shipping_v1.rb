# frozen_string_literal: true

require "peddler/api"

module Peddler
  class API
    # Selling Partner API for Direct Fulfillment Shipping
    #
    # The Selling Partner API for Direct Fulfillment Shipping provides programmatic access to a direct fulfillment
    # vendor's shipping data.
    class VendorDirectFulfillmentShippingV1 < API
      # Returns a list of shipping labels created during the time frame that you specify. You define that time frame
      # using the `createdAfter` and `createdBefore` parameters. You must use both of these parameters. The date range
      # to search must not be more than 7 days.
      #
      # @param [String] ship_from_party_id The vendor `warehouseId` for order fulfillment. If not specified, the result
      #   will contain orders for all warehouses.
      # @param [Integer] limit The limit to the number of records returned.
      # @param [String] created_after Shipping labels that became available after this date and time will be included in
      #   the result. Must be in [ISO 8601](https://developer-docs.amazon.com/sp-api/docs/iso-8601) date/time format.
      # @param [String] created_before Shipping labels that became available before this date and time will be included
      #   in the result. Must be in [ISO 8601](https://developer-docs.amazon.com/sp-api/docs/iso-8601) date/time format.
      # @param [String] sort_order Sort ASC or DESC by order creation date.
      # @param [String] next_token Used for pagination when there are more ship labels than the specified result size
      #   limit. The token value is returned in the previous API call.
      # @return [Hash] The API response
      def get_shipping_labels(created_after, created_before, ship_from_party_id: nil, limit: nil, sort_order: nil,
        next_token: nil)
        path = "/vendor/directFulfillment/shipping/v1/shippingLabels"
        params = {
          "shipFromPartyId" => ship_from_party_id,
          "limit" => limit,
          "createdAfter" => created_after,
          "createdBefore" => created_before,
          "sortOrder" => sort_order,
          "nextToken" => next_token,
        }.compact

        rate_limit(10.0).get(path, params:)
      end

      # Creates a shipping label for a purchase order and returns a `transactionId` for reference.
      #
      # @param [Hash] body Request body containing one or more shipping labels data.
      # @return [Hash] The API response
      def submit_shipping_label_request(body)
        path = "/vendor/directFulfillment/shipping/v1/shippingLabels"
        body = body

        rate_limit(10.0).post(path, body:)
      end

      # Returns a shipping label for the `purchaseOrderNumber` that you specify.
      #
      # @param [String] purchase_order_number The purchase order number for which you want to return the shipping label.
      #   It should be the same `purchaseOrderNumber` as received in the order.
      # @return [Hash] The API response
      def get_shipping_label(purchase_order_number)
        path = "/vendor/directFulfillment/shipping/v1/shippingLabels/#{purchase_order_number}"

        rate_limit(10.0).get(path)
      end

      # Submits one or more shipment confirmations for vendor orders.
      #
      # @param [Hash] body Request body containing the shipment confirmations data.
      # @return [Hash] The API response
      def submit_shipment_confirmations(body)
        path = "/vendor/directFulfillment/shipping/v1/shipmentConfirmations"
        body = body

        rate_limit(10.0).post(path, body:)
      end

      # This API call is only to be used by Vendor-Own-Carrier (VOC) vendors. Calling this API will submit a shipment
      # status update for the package that a vendor has shipped. It will provide the Amazon customer visibility on their
      # order, when the package is outside of Amazon Network visibility.
      #
      # @param [Hash] body Request body containing the shipment status update data.
      # @return [Hash] The API response
      def submit_shipment_status_updates(body)
        path = "/vendor/directFulfillment/shipping/v1/shipmentStatusUpdates"
        body = body

        rate_limit(10.0).post(path, body:)
      end

      # Returns a list of customer invoices created during a time frame that you specify. You define the time frame
      # using the `createdAfter` and `createdBefore` parameters. You must use both of these parameters. The date range
      # to search must be no more than 7 days.
      #
      # @param [String] ship_from_party_id The vendor `warehouseId` for order fulfillment. If not specified, the result
      #   will contain orders for all warehouses.
      # @param [Integer] limit The limit to the number of records returned
      # @param [String] created_after Orders that became available after this date and time will be included in the
      #   result. Must be in [ISO 8601](https://developer-docs.amazon.com/sp-api/docs/iso-8601) date/time format.
      # @param [String] created_before Orders that became available before this date and time will be included in the
      #   result. Must be in [ISO 8601](https://developer-docs.amazon.com/sp-api/docs/iso-8601) date/time format.
      # @param [String] sort_order Sort ASC or DESC by order creation date.
      # @param [String] next_token Used for pagination when there are more orders than the specified result size limit.
      #   The token value is returned in the previous API call.
      # @return [Hash] The API response
      def get_customer_invoices(created_after, created_before, ship_from_party_id: nil, limit: nil, sort_order: nil,
        next_token: nil)
        path = "/vendor/directFulfillment/shipping/v1/customerInvoices"
        params = {
          "shipFromPartyId" => ship_from_party_id,
          "limit" => limit,
          "createdAfter" => created_after,
          "createdBefore" => created_before,
          "sortOrder" => sort_order,
          "nextToken" => next_token,
        }.compact

        rate_limit(10.0).get(path, params:)
      end

      # Returns a customer invoice based on the `purchaseOrderNumber` that you specify.
      #
      # @param [String] purchase_order_number Purchase order number of the shipment for which to return the invoice.
      # @return [Hash] The API response
      def get_customer_invoice(purchase_order_number)
        path = "/vendor/directFulfillment/shipping/v1/customerInvoices/#{purchase_order_number}"

        rate_limit(10.0).get(path)
      end

      # Returns a list of packing slips for the purchase orders that match the criteria specified. Date range to search
      # must not be more than 7 days.
      #
      # @param [String] ship_from_party_id The vendor `warehouseId` for order fulfillment. If not specified the result
      #   will contain orders for all warehouses.
      # @param [Integer] limit The limit to the number of records returned
      # @param [String] created_after Packing slips that became available after this date and time will be included in
      #   the result. Must be in [ISO 8601](https://developer-docs.amazon.com/sp-api/docs/iso-8601) date/time format.
      # @param [String] created_before Packing slips that became available before this date and time will be included in
      #   the result. Must be in [ISO 8601](https://developer-docs.amazon.com/sp-api/docs/iso-8601) date/time format.
      # @param [String] sort_order Sort ASC or DESC by packing slip creation date.
      # @param [String] next_token Used for pagination when there are more packing slips than the specified result size
      #   limit. The token value is returned in the previous API call.
      # @return [Hash] The API response
      def get_packing_slips(created_after, created_before, ship_from_party_id: nil, limit: nil, sort_order: nil,
        next_token: nil)
        path = "/vendor/directFulfillment/shipping/v1/packingSlips"
        params = {
          "shipFromPartyId" => ship_from_party_id,
          "limit" => limit,
          "createdAfter" => created_after,
          "createdBefore" => created_before,
          "sortOrder" => sort_order,
          "nextToken" => next_token,
        }.compact

        rate_limit(10.0).get(path, params:)
      end

      # Returns a packing slip based on the `purchaseOrderNumber` that you specify.
      #
      # @param [String] purchase_order_number The `purchaseOrderNumber` for the packing slip you want.
      # @return [Hash] The API response
      def get_packing_slip(purchase_order_number)
        path = "/vendor/directFulfillment/shipping/v1/packingSlips/#{purchase_order_number}"

        rate_limit(10.0).get(path)
      end
    end
  end
end