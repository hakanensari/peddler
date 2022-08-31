# frozen_string_literal: true

require 'old_helper'
require 'peddler/structured_list'

class TestPeddlerStructuredList < MiniTest::Test
  def setup
    @list = Peddler::StructuredList.new('OrderStatus', 'Status')
  end

  def test_building_a_structured_list_for_a_single_value
    exp = { 'OrderStatus.Status.1' => 'foo' }
    assert_equal exp, @list.build('foo')
  end

  def test_building_a_structured_list_for_an_array_of_values
    exp = { 'OrderStatus.Status.1' => 'foo', 'OrderStatus.Status.2' => 'bar' }
    assert_equal exp, @list.build(%w[foo bar])
  end

  def test_flattening_nested_arrays_of_values
    exp = { 'OrderStatus.Status.1' => 'foo', 'OrderStatus.Status.2' => 'bar' }
    assert_equal exp, @list.build([%w[foo bar]])
  end

  def test_handling_single_key
    list = Peddler::StructuredList.new('Foo')
    exp = { 'Foo.1' => 'bar' }

    assert_equal exp, list.build('bar')
  end

  def test_handling_more_than_two_keys
    list = Peddler::StructuredList.new('QueryList', 'Query', '1', 'FilterOptions', 'FilterOption')
    exp = { 'QueryList.Query.1.FilterOptions.FilterOption.1' => 'foo' }

    assert_equal exp, list.build('foo')
  end
end
