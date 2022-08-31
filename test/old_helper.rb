# frozen_string_literal: true

# Keep SimpleCov at top.
if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start do
    add_filter '/test/'
  end
end

require 'ostruct'
require 'minitest/autorun'
require 'minitest/focus'
