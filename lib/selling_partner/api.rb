# frozen_string_literal: true

require 'http'

require 'selling_partner/client'

module SellingPartner
  # A Selling Partners API client
  class API
    include Client

    attr_reader :aws_access_key_id, :aws_secret_access_key, :aws_region

    # Creates a wrapper to a Selling Partner API
    #
    # @param aws_access_key_id [String] Your AWS access key identifier
    # @param aws_secret_access_key [String] Your AWS secret access key
    # @param aws_region [String] The AWS region to which you are directing your call
    def initialize(aws_access_key_id:,
                   aws_secret_access_key:,
                   aws_region:)
      @aws_access_key_id = aws_access_key_id
      @aws_secret_access_key = aws_secret_access_key
      @aws_region = aws_region
    end

    private

    def endpoint
      Endpoint.find!(aws_region).uri
    end
  end
end
