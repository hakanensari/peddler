# frozen_string_literal: true

require 'old_helper'
require 'peddler/operation'

class TestPeddlerOperation < MiniTest::Test
  def setup
    @operation = Peddler::Operation.new('Foo')
  end

  def test_that_it_converts_key_to_structured_list
    @operation.store('FooStatus', [1, 2])
    @operation.structure!('FooStatus', 'Foo')
    refute @operation.key?('FooStatus')
    assert_equal 1, @operation['FooStatus.Foo.1']
    assert_equal 2, @operation['FooStatus.Foo.2']
  end

  def test_that_it_converts_nested_keys_to_structured_list
    @operation.store('Foo.1.Status', [{ 'Baz' => 1 }])
    @operation.store('Foo.2.Status', [{ 'Baz' => 2 }])
    @operation.structure!('Status', 'Bar')
    refute @operation.key?('Foo.1.Status')
    refute @operation.key?('Foo.2.Status')
    assert_equal 1, @operation['Foo.1.Status.Bar.1.Baz']
    assert_equal 2, @operation['Foo.2.Status.Bar.1.Baz']
  end

  def test_that_store_camelizes_symbol_key
    @operation.store(:foo_bar, 'baz')
    assert @operation.key?('FooBar')
    refute @operation.key?(:foo_bar)
  end

  def test_that_store_wont_camelize_string_key
    @operation.store('foo_bar', 'baz')
    assert @operation.key?('foo_bar')
    refute @operation.key?('FooBar')
  end

  def test_that_store_wont_camelize_symbol_key_with_capital_letter
    @operation.store(:MarketplaceId, '1')
    assert @operation.key?('MarketplaceId')
  end

  def test_that_store_upcases_sku
    @operation.store(:seller_sku, 'foo')
    assert @operation.key?('SellerSKU')
    refute @operation.key?(:seller_sku)
  end

  def test_that_store_upcases_cod
    @operation.store(:include_cod_fulfillment_preview, 'foo')
    assert @operation.key?('IncludeCODFulfillmentPreview')
    refute @operation.key?(:include_cod_fulfillment_preview)
  end

  def test_that_store_formats_time_values
    time = Time.new(2018, 1, 1, 0, 0, 0, 0)
    @operation.store('time', time)
    assert_equal '2018-01-01T00:00:00.00Z', @operation.fetch('time')
  end

  def test_that_store_formats_date_values
    date = Date.new(2018, 1, 1)
    @operation.store('date', date)
    assert_equal '2018-01-01', @operation.fetch('date')
  end

  def test_stringifying_hash_values
    @operation.store('Foo', bar: 1)
    assert_equal 1, @operation.fetch('Foo.Bar')
    refute @operation.key?('Foo')
  end

  def test_stringifying_nested_hash_values
    @operation.store('Foo', bar: { baz: 1 })
    assert_equal 1, @operation.fetch('Foo.Bar.Baz')
    refute @operation.key?('Foo')
  end

  def test_stringifying_struct_values
    @operation.store('Foo', Struct.new(:bar, :baz).new(1, 2))
    assert_equal 1, @operation.fetch('Foo.Bar')
    assert_equal 2, @operation.fetch('Foo.Baz')
  end

  def test_that_update_returns_delegator
    assert_kind_of Peddler::Operation, @operation.add(foo: 'bar')
  end
end
