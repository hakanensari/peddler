# frozen_string_literal: true

require 'forwardable'
require 'jeff'
require 'peddler/errors/builder'
require 'peddler/marketplace'
require 'peddler/operation'
require 'peddler/parser'

module Peddler
  # An abstract client
  #
  # Subclass this to implement an MWS API section.
  class Client
    extend Forwardable
    include Jeff

    class << self
      # @!visibility private
      attr_accessor :parser, :path, :version

      private

      def inherited(base)
        super
        base.parser = parser
        base.params params
      end
    end

    params 'SellerId' => -> { merchant_id },
           'MWSAuthToken' => -> { auth_token },
           'Version' => -> { version }
    self.parser = Parser

    def_delegators :marketplace, :host, :encoding
    def_delegators :'self.class', :parser, :version

    # Creates a new client
    # @param [Hash] opts
    # @option opts [String] :aws_access_key_id
    # @option opts [String] :aws_secret_access_key
    # @option opts [String, Peddler::Marketplace] :marketplace
    # @option opts [String] :merchant_id
    # @option opts [String] :auth_token
    def initialize(opts = {})
      opts.each { |k, v| send("#{k}=", v) }
    end

    # The MWS Auth Token for a seller's account
    # @note You can omit this if you are accessing your own seller account
    # @return [String]
    attr_accessor :auth_token

    # The seller's Merchant ID
    # @note Amazon also refers to this as Seller ID or Merchant Token
    # @return [String]
    attr_accessor :merchant_id

    # The marketplace where you signed up as application developer
    # @note You can pass the two-letter country code of the marketplace as
    #   shorthand when setting
    # @return [Peddler::Marketplace]
    attr_reader :marketplace

    # @!parse attr_writer :marketplace
    def marketplace=(marketplace)
      @marketplace =
        if marketplace.is_a?(Marketplace)
          marketplace
        else
          Marketplace.find(marketplace)
        end
    end

    # The body of the HTTP request
    # @return [String]
    attr_reader :body

    # @!parse attr_writer :body
    def body=(str)
      str ? add_content(str) : clear_content!
    end

    # @!visibility private
    attr_writer :path

    # @!visibility private
    def path
      @path ||= self.class.path
    end

    # @!visibility private
    def defaults
      @defaults ||= {}
    end

    # @!visibility private
    def headers
      @headers ||= {}
    end

    # @!visibility private
    def aws_endpoint
      "https://#{host}#{path}"
    end

    # @!visibility private
    def operation(action = nil)
      action ? @operation = Operation.new(action) : @operation
    end

    # @!visibility private
    def run(&block)
      opts = build_options
      res = post(opts)
      unless res.status == 200
        handle_http_status_error(res)
        return res
      end

      self.body = nil
      if block
        res.body.each do |chunk|
          yield(chunk, nil, nil)
        end
      else
        parser.new(res, encoding)
      end
    end

    private

    def clear_content!
      headers.delete('Content-Type')
      @body = nil
    end

    def add_content(content)
      @body = content
      if content.encoding.names.include?('BINARY')
        headers['Content-Type'] = 'application/octet-stream'
      elsif content.start_with?('<?xml')
        headers['Content-Type'] = 'text/xml'
      else
        headers['Content-Type'] =
          "text/tab-separated-values; charset=#{encoding}"
        @body = @body.encode(encoding)
      end
    end

    def extract_options(args)
      args.last.is_a?(Hash) ? args.pop : {}
    end

    def build_options
      opts = defaults.merge(params: operation, headers: headers)
      body ? opts.update(body: body) : opts
    end

    def handle_http_status_error(res)
      new_error = Errors::Builder.call(res)
      raise new_error if new_error
    end
  end
end
