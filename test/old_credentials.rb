# frozen_string_literal: true

require 'forwardable'
require 'yaml'

module OldCredentials
  class << self
    extend Forwardable
    include Enumerable

    attr_reader :all

    def_delegators :all, :each
  end

  %w[mws.yml mws.example.yml].each do |path|
    file = File.expand_path("../#{path}", __FILE__)
    if File.exist?(file)
      @all = YAML.load_file(file)
      break
    end
  end
end
