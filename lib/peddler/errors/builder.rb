# frozen_string_literal: true

require 'peddler/errors/class_generator'
require 'peddler/errors/parser'

module Peddler
  module Errors
    # @!visibility private
    class Builder
      DIGIT_AS_FIRST_CHAR = /^\d/.freeze
      private_constant :DIGIT_AS_FIRST_CHAR

      attr_reader :response

      def self.call(response)
        new(response).build
      end

      def initialize(response)
        @response = Parser.new(response)
      end

      def build
        return if no_error_response?
        return if bad_class_name?

        error_class.new(error_message, response.__getobj__)
      end

      private

      def bad_class_name?
        error_name.match?(DIGIT_AS_FIRST_CHAR)
      end

      def no_error_response?
        response.parse.nil?
      end

      def error_class
        ClassGenerator.call(error_name)
      end

      def error_name
        response.code
      end

      def error_message
        response.message
      end
    end
  end
end
