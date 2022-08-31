# frozen_string_literal: true

module SellingPartner
  # @!visibility private
  # @see https://developer-docs.amazon.com/sp-api/docs/sp-api-endpoints
  class Endpoint
    NotFound = Class.new(ArgumentError)

    attr_reader :aws_region, :uri

    def self.all
      @all ||= YAML.load_file(File.join(__dir__, 'endpoint.yml'), symbolize_names: true).map { |values| new(**values) }
    end

    def self.find(aws_region)
      all.find { |endpoint| endpoint.aws_region == aws_region }
    end

    def self.find!(aws_region)
      find(aws_region) || raise(NotFound, %("#{aws_region}" isn't associated with any Selling Partner endpoint))
    end

    def initialize(aws_region:, uri:)
      @aws_region = aws_region
      @uri = uri
    end

    # @see https://developer-docs.amazon.com/sp-api/docs/the-selling-partner-api-sandbox#selling-partner-api-sandbox-endpoints
    def sandbox_uri
      uri.sub('sellingpartnerapi', 'sandbox.sellingpartnerapi')
    end
  end
end
