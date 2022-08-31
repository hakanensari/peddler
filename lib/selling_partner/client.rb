# frozen_string_literal: true

require 'http'

require 'peddler/version'

module SellingPartner
  # @!visibility private
  module Client
    def client
      @client ||= build_client
    end

    private

    def build_client
      HTTP::Client.new.headers('User-Agent' => user_agent)
    end

    def user_agent
      "Peddler/#{Peddler::VERSION} (Language=Ruby; #{Socket.gethostname})"
    end
  end
end
