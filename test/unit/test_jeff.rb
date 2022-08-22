# frozen_string_literal: true

require 'minitest/autorun'
require 'jeff'

# We may need to set ciphers explicitly on jRuby
# see https://github.com/jruby/warbler/issues/340
Excon.defaults[:ciphers] = 'DEFAULT' if RUBY_ENGINE == 'jruby'

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
    assert_includes client.connection.data[:headers]['User-Agent'], 'Peddler'
  end

  def test_allows_customizing_user_agent
    @klass.user_agent = 'CustomApp/1.0'
    client = @klass.new
    client.aws_endpoint = 'http://example.com/'
    assert_equal 'CustomApp/1.0', client.connection.data[:headers]['User-Agent']
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

  def teardown
    Excon.stubs.clear
  end

  Excon::HTTP_VERBS.each do |method|
    define_method "test_makes_#{method}_request" do
      Excon.stub({}, status: 200)
      assert_equal 200, @client.send(method, mock: true).status
    end
  end

  def test_adds_content_md5_request_header_if_given_a_request_body
    Excon.stub({}) do |request_params|
      { body: request_params[:query]['ContentMD5Value'] }
    end
    refute_empty @client.post(body: 'foo', mock: true).body
  end

  def test_moves_query_to_body_if_post
    Excon.stub({}) do |request_params|
      { body: request_params[:body] }
    end

    res = @client.post(query: { foo: 'bar' }, mock: true)
    assert_includes res.body, 'foo=bar'
  end

  def test_does_not_move_query_to_body_if_body_is_set
    Excon.stub({}) do |request_params|
      { body: request_params[:body] }
    end

    res = @client.post(query: { foo: 'bar' }, body: 'baz', mock: true)
    assert_equal 'baz', res.body
  end

  def test_does_not_move_query_to_body_if_not_post
    Excon.stub({}) do |request_params|
      { body: request_params[:body] }
    end

    res = @client.get(query: { foo: 'bar' }, mock: true)
    assert_nil res.body
  end

  def test_sets_proper_encoding_header
    Excon.stub({}) do |request_params|
      { headers: request_params[:headers] }
    end

    res = @client.post(query: { foo: 'bar' }, mock: true)
    assert_includes res.headers['Content-Type'], 'UTF-8'
  end

  # def test_gets_from_an_actual_endpoint
  #   @client.aws_endpoint = 'https://mws.amazonservices.com/Sellers/2011-07-01'
  #   res = @client.post(query: { 'Action' => 'GetServiceStatus' })
  #   assert_equal 200, res.status
  # end

  def test_has_no_proxy_by_default
    refute @client.connection.data[:proxy]
  end

  def test_sets_proxy
    @client.proxy = 'http://my.proxy:4321'
    assert @client.connection.data[:proxy]
  end
end
