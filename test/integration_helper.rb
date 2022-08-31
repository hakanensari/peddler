# frozen_string_literal: true

require 'credentials'
require 'old_helper'
require 'recorder'

class IntegrationTest < MiniTest::Test
  include Recorder

  class << self
    def use(endpoint)
      @current_endpoint = endpoint
    end

    def clients
      klass = MWS.const_get("#{current_endpoint}::Client")
      ::Credentials.to_a.shuffle.each_with_object([]) do |credentials, memo|
        client = klass.new(credentials)
        country_code = client.marketplace.country_code
        memo.define_singleton_method(country_code.downcase) { client }
        memo << client
      end
    end

    private

    def current_endpoint
      @current_endpoint ||= name.sub('Test', '')
    end
  end

  def clients
    self.class.clients
  end
end

::Peddler::VCRMatcher.ignore_seller!

VCR.configure do |c|
  c.before_record do |interaction|
    %w[
      BuyerName BuyerEmail Name AddressLine1 City StateOrProvinceCode PostalCode
      Phone Amount AmazonOrderId SellerOrderId
    ].each do |key|
      interaction.response.body.gsub!(/<#{key}>[^<]+</, "<#{key}>FILTERED<")
    end
  end

  Credentials.each do |record|
    c.filter_sensitive_data('MERCHANT_ID') { record['merchant_id'] }
    c.filter_sensitive_data('AWS_ACCESS_KEY_ID') { record['aws_access_key_id'] }
  end
end
