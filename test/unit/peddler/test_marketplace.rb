# frozen_string_literal: true

require 'old_helper'
require 'peddler/marketplace'

class TestPeddlerMarketplace < MiniTest::Test
  def setup
    @marketplace = Peddler::Marketplace.find('ATVPDKIKX0DER')
  end

  def test_country_code
    assert @marketplace.country_code
  end

  def test_host
    assert @marketplace.host
  end

  def test_encoding
    assert @marketplace.encoding
  end

  def test_guard_against_missing_country_code
    error = assert_raises ArgumentError do
      Peddler::Marketplace.find(nil)
    end
    assert_equal 'missing marketplace', error.message
  end

  def test_guard_against_invalid_country_code
    error = assert_raises ArgumentError do
      Peddler::Marketplace.find('FOO')
    end
    assert_equal '"FOO" is not a valid marketplace', error.message
  end

  class TestFindByCountryCode < TestPeddlerMarketplace
    def setup
      @marketplace = Peddler::Marketplace.find('US')
    end

    def test_translation_of_uk_to_gb
      marketplace = Peddler::Marketplace.find('UK')
      assert_equal 'GB', marketplace.country_code
    end
  end
end
