# frozen_string_literal: true

require 'selling_partner/client'

module SellingPartner
  # @see https://developer-docs.amazon.com/sp-api/docs/connecting-to-the-selling-partner-api
  class AccessToken
    include Client

    attr_reader :client_id, :client_secret

    # @param client_id [String] Your LWA client identifier
    # @param client_secret [String] Your LWA client secret
    def initialize(client_id, client_secret)
      @client_id = client_id
      @client_secret = client_secret
    end

    def request_with_refresh_token(refresh_token)
      request('refresh_token', refresh_token: refresh_token)
    end

    def request_for_grantless_operations(scope)
      request('client_credentials', scope: scope)
    end

    private

    def request(grant_type, refresh_token: nil, scope: nil)
      uri = 'https://api.amazon.com/auth/o2/token'
      params = {
        grant_type: grant_type,
        refresh_token: refresh_token,
        scope: scope,
        client_id: client_id,
        client_secret: client_secret
      }.compact

      response = client.post(uri, form: params)

      response.parse['access_token']
    end
  end
end
