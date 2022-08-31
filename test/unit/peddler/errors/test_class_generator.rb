# frozen_string_literal: true

require 'old_helper'
require 'peddler/errors/class_generator'

module Peddler
  class TestErrorsClassGenerator < MiniTest::Test
    def setup
      @error_name = 'Foo'
    end

    def teardown
      Errors.send(:remove_const, @error_name)
    end

    def test_building_an_error_class
      Errors::ClassGenerator.call(@error_name)
      assert Peddler::Errors.const_get(@error_name)
    end

    def test_thread_safety
      Errors::ClassGenerator.call(@error_name)
      assert_silent do
        Peddler::Errors::ClassGenerator.call(@error_name)
      end
    end

    def test_defined_error
      Errors.const_set(@error_name, Class.new(Errors::Error))
      Errors::ClassGenerator.call(@error_name)
      assert Peddler::Errors.const_get(@error_name)
    end

    def test_incorrect_type
      Errors.const_set(@error_name, StandardError)
      assert_raises TypeError do
        Errors::ClassGenerator.call(@error_name)
      end
    end
  end
end
