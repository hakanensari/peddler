# frozen_string_literal: true

require 'peddler/client'

module MWS
  module FulfillmentOutboundShipment
    # The Fulfillment Outbound Shipment API enables you to fulfill orders placed
    # through channels other than Amazon's retail web site, using your inventory
    # in the Amazon Fulfillment Network. You can request previews of potential
    # fulfillment orders that return estimated shipping fees and shipping dates
    # based on shipping speed. You can get detailed item-level, shipment-level,
    # and order-level information for any existing fulfillment order that you
    # specify. You can also request lists of existing fulfillment orders based
    # on when they were fulfilled and by the fulfillment method associated with
    # them.
    class Client < ::Peddler::Client
      self.version = '2010-10-01'
      self.path = "/FulfillmentOutboundShipment/#{version}"

      # Lists fulfillment order previews
      #
      # @see https://docs.developer.amazonservices.com/en_US/fba_outbound/FBAOutbound_GetFulfillmentPreview.html
      # @param [Struct, Hash] address
      # @param [Array<Struct, Hash>] items
      # @param [Hash] opts
      # @option opts Array[String] :shipping_speed_categories
      # @option opts [Boolean] :include_cod_fulfillment_preview
      # @return [Peddler::XMLParser]
      def get_fulfillment_preview(address, items, opts = {})
        operation('GetFulfillmentPreview')
          .add(opts)
          .add('Address' => address, 'Items' => items)
          .structure!('Items', 'member')
          .structure!('ShippingSpeedCategories', 'member')

        run
      end

      # Requests that Amazon ship items from the seller's Amazon Fulfillment
      # Network inventory to a destination address
      #
      # @see https://docs.developer.amazonservices.com/en_US/fba_outbound/FBAOutbound_CreateFulfillmentOrder.html
      # @param [String] seller_fulfillment_order_id
      # @param [String] displayable_order_id
      # @param [String, #iso8601] displayable_order_date_time
      # @param [String] displayable_order_comment
      # @param [String] shipping_speed_category
      # @param [Struct, Hash] destination_address
      # @param [Array<Struct, Hash>] items
      # @param [Hash] opts
      # @option opts [String] :fulfillment_action
      # @option opts [String] :fulfillment_policy
      # @option opts [Array<String>] :notification_email_list
      # @option opts [Struct, Hash] :cod_settings
      # @return [Peddler::XMLParser]
      def create_fulfillment_order(seller_fulfillment_order_id,
                                   displayable_order_id,
                                   displayable_order_date_time,
                                   displayable_order_comment,
                                   shipping_speed_category,
                                   destination_address, items, opts = {})
        operation('CreateFulfillmentOrder')
          .add(opts)
          .add('SellerFulfillmentOrderId' => seller_fulfillment_order_id,
               'DisplayableOrderId' => displayable_order_id,
               'DisplayableOrderDateTime' => displayable_order_date_time,
               'DisplayableOrderComment' => displayable_order_comment,
               'ShippingSpeedCategory' => shipping_speed_category,
               'DestinationAddress' => destination_address,
               'Items' => items)
          .structure!('Items', 'member')
          .structure!('NotificationEmailList', 'member')

        run
      end

      # Updates and/or requests shipment for a fulfillment order with an order
      # hold on it
      #
      # @see https://docs.developer.amazonservices.com/en_US/fba_outbound/FBAOutbound_UpdateFulfillmentOrder.html
      # @param [String] seller_fulfillment_order_id
      # @param [Hash] opts
      # @option opts [String] :fulfillment_action
      # @option opts [String] :displayable_order_id
      # @option opts [String, #iso8601] :displayable_order_date_time
      # @option opts [String] :displayable_order_comment
      # @option opts [String] :shipping_speed_category
      # @option opts [Struct, Hash] :destination_address
      # @option opts [String] :fulfillment_policy
      # @option opts [Array<String>] :notification_email_list
      # @option opts [Array<Struct, Hash>] :items
      # @return [Peddler::XMLParser]
      def update_fulfillment_order(seller_fulfillment_order_id, opts = {})
        operation('UpdateFulfillmentOrder')
          .add(opts)
          .add('SellerFulfillmentOrderId' => seller_fulfillment_order_id)
          .structure!('NotificationEmailList', 'member')
          .structure!('Items', 'member')

        run
      end

      # Gets a fulfillment order
      #
      # @see https://docs.developer.amazonservices.com/en_US/fba_outbound/FBAOutbound_GetFulfillmentOrder.html
      # @param [String] seller_fulfillment_order_id
      # @return [Peddler::XMLParser]
      def get_fulfillment_order(seller_fulfillment_order_id)
        operation('GetFulfillmentOrder')
          .add('SellerFulfillmentOrderId' => seller_fulfillment_order_id)

        run
      end

      # Returns a list of fulfillment orders fulfilled on or after a date
      #
      # @see https://docs.developer.amazonservices.com/en_US/fba_outbound/FBAOutbound_ListAllFulfillmentOrders.html
      # @param [Hash] opts
      # @option opts [String, #iso8601] :query_start_date_time
      # @return [Peddler::XMLParser]
      def list_all_fulfillment_orders(opts = {})
        operation('ListAllFulfillmentOrders')
          .add(opts)

        run
      end

      # Returns the next page of fulfillment orders
      #
      # @see https://docs.developer.amazonservices.com/en_US/fba_outbound/FBAOutbound_ListAllFulfillmentOrdersByNextToken.html
      # @param [String] next_token
      # @return [Peddler::XMLParser]
      def list_all_fulfillment_orders_by_next_token(next_token)
        operation('ListAllFulfillmentOrdersByNextToken')
          .add('NextToken' => next_token)

        run
      end

      # Returns delivery tracking information for a package in an outbound
      # shipment for a Multi-Channel Fulfillment order
      #
      # @see https://docs.developer.amazonservices.com/en_US/fba_outbound/FBAOutbound_GetPackageTrackingDetails.html
      # @param [String] package_number
      # @return [Peddler::XMLParser]
      def get_package_tracking_details(package_number)
        operation('GetPackageTrackingDetails')
          .add('PackageNumber' => package_number)

        run
      end

      # Requests that Amazon stop attempting to fulfill an existing fulfillment
      # order
      #
      # @see https://docs.developer.amazonservices.com/en_US/fba_outbound/FBAOutbound_CancelFulfillmentOrder.html
      # @param [String] seller_fulfillment_order_id
      # @return [Peddler::XMLParser]
      def cancel_fulfillment_order(seller_fulfillment_order_id)
        operation('CancelFulfillmentOrder')
          .add('SellerFulfillmentOrderId' => seller_fulfillment_order_id)

        run
      end

      # Returns a list of return reason codes for a seller SKU in a given
      # marketplace.
      #
      # @see https://docs.developer.amazonservices.com/en_US/fba_outbound/FBAOutbound_ListReturnReasonCodes.html
      # @param [String] seller_sku
      # @param [Hash] opts
      # @option opts [String] :marketplace_id
      # @option opts [String] :seller_fulfillment_order_id
      # @option opts [String] :language
      # @return [Peddler::XMLParser]
      def list_return_reason_codes(seller_sku, opts = {})
        operation('ListReturnReasonCodes')
          .add(opts)
          .add('SellerSKU' => seller_sku)
          .structure!('List', 'member')

        run
      end

      # Creates a fulfillment return.
      #
      # @see https://docs.developer.amazonservices.com/en_US/fba_outbound/FBAOutbound_CreateFulfillmentReturn.html
      # @param [String] seller_fulfillment_order_id
      # @param [Array] items
      # @return [Peddler::XMLParser]
      def create_fulfillment_return(seller_fulfillment_order_id, items)
        operation('CreateFulfillmentReturn')
          .add('SellerFulfillmentOrderId' => seller_fulfillment_order_id,
               'Items' => items)
          .structure!('Items', 'member')

        run
      end

      # Gets the operational status of the API
      #
      # @see https://docs.developer.amazonservices.com/en_US/fba_outbound/MWS_GetServiceStatus.html
      # @return [Peddler::XMLParser]
      def get_service_status
        operation('GetServiceStatus')
        run
      end
    end
  end
end
