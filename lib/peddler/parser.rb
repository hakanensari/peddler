# frozen_string_literal: true

require 'peddler/flat_file_parser'
require 'peddler/xml_response_parser'

module Peddler
  # @!visibility private
  module Parser
    class << self
      # We're massaging data produced by a motley army of developers. It's
      # messy.
      def new(res, encoding)
        # Don't parse if there's no body
        return res unless res.body

        if xml?(res)
          XMLResponseParser.new(res)
        else
          # Amazon returns a variety of content types for flat files. I simply
          # assume anything not XML is a flat file.
          FlatFileParser.new(res, encoding)
        end
      end

      def xml?(res)
        return true if res.headers['Content-Type'].start_with?('text/xml')
        return true if res.body.to_s.start_with?('<?xml')

        false
      end
    end
  end
end
