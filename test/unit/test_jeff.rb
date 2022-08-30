# frozen_string_literal: true

require 'helper'
require 'jeff'

class TestJeff < Minitest::Test
  def setup
    @klass = Class.new { include Jeff }
  end

  def test_delegates_unset_aws_credential_to_env_vars
    key = '123456'
    client = @klass.new
    %w[aws_access_key_id aws_secret_access_key].each do |attr|
      ENV[attr.upcase] = key
      assert_equal key, client.send(attr)
      ENV[attr.upcase] = nil
      refute_equal key, client.send(attr)
    end
  end

  def test_has_required_request_query_parameters
    %w[AWSAccessKeyId SignatureMethod SignatureVersion Timestamp].each do |key|
      assert @klass.params.key?(key)
    end
  end

  def test_configures_request_query_parameters
    @klass.params 'Foo' => 'bar'
    assert @klass.params.key?('Foo')
  end

  def test_allows_dynamic_values_for_request_query_parameters
    @klass.params 'Foo' => -> { bar }
    client = @klass.new
    def client.bar
      'baz'
    end
    assert_equal client.bar, client.send(:default_query_values).fetch('Foo')
    assert_kind_of Proc, @klass.params['Foo']
  end

  def test_discards_request_query_parameters_with_nil_values
    @klass.params 'Foo' => -> { bar }
    client = @klass.new
    def client.bar; end
    refute client.send(:default_query_values).key?('Foo')
  end

  def test_requires_signature
    signature = Jeff::Signature.new(nil)
    assert_raises(ArgumentError) { signature.sign('foo') }
  end

  def test_sorts_request_query_parameters_lexicographically
    query = Jeff::Query.new('A10' => 1, 'A1' => 1)
    assert_equal 'A1=1&A10=1', query.to_s
  end

  def test_handles_symbol_keys
    query = Jeff::Query.new(foo: 1, bar: 2)
    assert_equal 'bar=2&foo=1', query.to_s
  end

  def test_sets_user_agent_header
    client = @klass.new
    client.aws_endpoint = 'http://example.com/'
    assert_includes client.connection.default_options.headers['User-Agent'], 'Peddler'
  end

  def test_allows_customizing_user_agent
    @klass.user_agent = 'CustomApp/1.0'
    client = @klass.new
    client.aws_endpoint = 'http://example.com/'
    assert_equal 'CustomApp/1.0', client.connection.default_options.headers['User-Agent']
  end

  def test_escapes_space
    assert_equal '%20', Jeff::Utils.escape(' ')
    query = Jeff::Query.new('foo' => 'bar baz')
    assert_equal 'foo=bar%20baz', query.to_s
  end

  def test_escapes_multibyte_character
    assert_equal '%E2%80%A6', Jeff::Utils.escape('…')
  end

  def test_does_not_escape_tilde
    assert_equal '~%2C', Jeff::Utils.escape('~,')
  end
end

class TestJeffInAction < Minitest::Test
  def setup
    klass = Class.new { include Jeff }
    @client = klass.new
    @client.aws_endpoint = 'http://example.com/'
    @client.aws_access_key_id = 'foo'
    @client.aws_secret_access_key = 'bar'
  end

  def test_adds_default_query_values
    options = {}
    options = @client.add_default_query_values(options)
    refute_empty options[:params]
  end

  def test_adds_content_md5_request_header_if_given_a_request_body
    options = { body: 'foo' }
    options = @client.add_md5_digest(options)
    assert options[:params]['ContentMD5Value']
  end

  def test_moves_query_to_body_if_post
    options = { params: { foo: 'bar' } }
    options = @client.move_query_to_body('post', options)
    assert_equal 'foo=bar', options[:body]
  end

  def test_does_not_move_query_to_body_if_post_but_body_is_set
    options = { params: { foo: 'bar' }, body: 'baz' }
    options = @client.move_query_to_body('post', options)
    assert_equal 'baz', options[:body]
  end

  def test_does_not_move_query_to_body_if_not_post
    options = { params: { foo: 'bar' } }
    options = @client.move_query_to_body('get', options)
    assert_nil options[:body]
  end

  def test_sets_proper_encoding_header
    options = { params: { foo: 'bar' } }
    options = @client.move_query_to_body('post', options)
    assert_includes options[:headers]['Content-Type'], 'UTF-8'
  end

  def test_has_no_proxy_by_default
    assert_empty @client.connection.default_options.proxy
  end

  def test_sets_proxy
    @client.proxy = 'http://my.proxy:4321'
    refute_empty @client.connection.default_options.proxy
  end
end
