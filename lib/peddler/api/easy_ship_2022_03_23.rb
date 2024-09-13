# frozen_string_literal: true

require "peddler/api"

module Peddler
  class API
    # Selling Partner API for Easy Ship
    #
    # The Selling Partner API for Easy Ship helps you build applications that help sellers manage and ship Amazon Easy
    # Ship orders. Your Easy Ship applications can: * Get available time slots for packages to be scheduled for
    # delivery. * Schedule, reschedule, and cancel Easy Ship orders. * Print labels, invoices, and warranties. See the
    # [Marketplace Support Table](doc:easyship-api-v2022-03-23-use-case-guide#marketplace-support-table) for the
    # differences in Easy Ship operations by marketplace.
    class EasyShip20220323 < API
      # Returns time slots available for Easy Ship orders to be scheduled based on the package weight and dimensions
      # that the seller specifies. This operation is available for scheduled and unscheduled orders based on marketplace
      # support. See **Get Time Slots** in the [Marketplace Support
      # Table](doc:easyship-api-v2022-03-23-use-case-guide#marketplace-support-table). This operation can return time
      # slots that have either pickup or drop-off handover methods - see **Supported Handover Methods** in the
      # [Marketplace Support Table](doc:easyship-api-v2022-03-23-use-case-guide#marketplace-support-table).
      #
      # @param [Hash] list_handover_slots_request The request schema for the `listHandoverSlots` operation.
      # @return [Hash] The API response
      def list_handover_slots(list_handover_slots_request: nil)
        path = "/easyShip/2022-03-23/timeSlot"
        body = list_handover_slots_request

        rate_limit(1.0).post(path, body:)
      end

      # Returns information about a package, including dimensions, weight, time slot information for handover, invoice
      # and item information, and status.
      #
      # @param [String] amazon_order_id An Amazon-defined order identifier. Identifies the order that the seller wants
      #   to deliver using Amazon Easy Ship.
      # @param [String] marketplace_id An identifier for the marketplace in which the seller is selling.
      # @return [Hash] The API response
      def get_scheduled_package(amazon_order_id, marketplace_id)
        path = "/easyShip/2022-03-23/package"
        params = {
          "amazonOrderId" => amazon_order_id,
          "marketplaceId" => marketplace_id,
        }.compact

        rate_limit(1.0).get(path, params:)
      end

      # Schedules an Easy Ship order and returns the scheduled package information. This operation does the following: *
      # Specifies the time slot and handover method for the order to be scheduled for delivery. * Updates the Easy Ship
      # order status. * Generates a shipping label and an invoice. Calling `createScheduledPackage` also generates a
      # warranty document if you specify a `SerialNumber` value. To get these documents, see [How to get invoice,
      # shipping label, and warranty documents](doc:easyship-api-v2022-03-23-use-case-guide). * Shows the status of Easy
      # Ship orders when you call the `getOrders` operation of the Selling Partner API for Orders and examine the
      # `EasyShipShipmentStatus` property in the response body. See the **Shipping Label**, **Invoice**, and
      # **Warranty** columns in the [Marketplace Support
      # Table](doc:easyship-api-v2022-03-23-use-case-guide#marketplace-support-table) to see which documents are
      # supported in each marketplace.
      #
      # @param [Hash] create_scheduled_package_request The request schema for the `createScheduledPackage` operation.
      # @return [Hash] The API response
      def create_scheduled_package(create_scheduled_package_request)
        path = "/easyShip/2022-03-23/package"
        body = create_scheduled_package_request

        rate_limit(1.0).post(path, body:)
      end

      # Updates the time slot for handing over the package indicated by the specified `scheduledPackageId`. You can get
      # the new `slotId` value for the time slot by calling the `listHandoverSlots` operation before making another
      # `patch` call. See the **Update Package** column in the [Marketplace Support
      # Table](doc:easyship-api-v2022-03-23-use-case-guide#marketplace-support-table) to see which marketplaces this
      # operation is supported in.
      #
      # @param [Hash] update_scheduled_packages_request The request schema for the `updateScheduledPackages` operation.
      # @return [Hash] The API response
      def update_scheduled_packages(update_scheduled_packages_request: nil)
        path = "/easyShip/2022-03-23/package"
        body = update_scheduled_packages_request

        rate_limit(1.0).patch(path, body:)
      end

      # This operation automatically schedules a time slot for all the `amazonOrderId`s given as input, generating the
      # associated shipping labels, along with other compliance documents according to the marketplace (refer to the
      # [marketplace document support table](doc:easyship-api-v2022-03-23-use-case-guide#marketplace-support-table)).
      # Developers calling this operation may optionally assign a `packageDetails` object, allowing them to input a
      # preferred time slot for each order in ther request. In this case, Amazon will try to schedule the respective
      # packages using their optional settings. On the other hand, *i.e.*, if the time slot is not provided, Amazon will
      # then pick the earliest time slot possible. Regarding the shipping label's file format, external developers are
      # able to choose between PDF or ZPL, and Amazon will create the label accordingly. This operation returns an array
      # composed of the scheduled packages, and a short-lived URL pointing to a zip file containing the generated
      # shipping labels and the other documents enabled for your marketplace. If at least an order couldn't be
      # scheduled, then Amazon adds the `rejectedOrders` list into the response, which contains an entry for each order
      # we couldn't process. Each entry is composed of an error message describing the reason of the failure, so that
      # sellers can take action. The table below displays the supported request and burst maximum rates:
      #
      # @param [Hash] create_scheduled_packages_request The request schema for the `createScheduledPackageBulk`
      #   operation.
      # @return [Hash] The API response
      def create_scheduled_package_bulk(create_scheduled_packages_request)
        path = "/easyShip/2022-03-23/packages/bulk"
        body = create_scheduled_packages_request

        rate_limit(1.0).post(path, body:)
      end
    end
  end
end