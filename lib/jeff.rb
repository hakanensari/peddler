# frozen_string_literal: true

require 'excon'

require 'base64'
require 'openssl'
require 'time'

require 'peddler/version'

# Jeff mixes in client behaviour for Amazon Web Services (AWS) that require
# Signature version 2 authentication.
module Jeff
  # Converts query field-value pairs to a sorted query string.
  class Query
    attr_reader :values

    def initialize(values)
      @values = values
    end

    def to_s
      values
        .sort { |a, b| a[0].to_s <=> b[0].to_s }
        .map { |k, v| "#{k}=#{Utils.escape(v)}" }.join('&')
    end
  end

  # Calculates an MD5sum for file being uploaded.
  class Content
    attr_reader :body

    def initialize(body)
      @body = body
    end

    def md5
      Base64.encode64(OpenSSL::Digest::MD5.digest(body)).strip
    end
  end

  # Signs an AWS request.
  class Signer
    attr_reader :method, :host, :path, :query_string

    def initialize(method, host, path, query_string)
      @method = method.upcase
      @host = host
      @path = path
      @query_string = query_string
    end

    def sign_with(aws_secret_access_key)
      Signature.new(aws_secret_access_key).sign(string_to_sign)
    end

    def string_to_sign
      [method, host, path, query_string].join("\n")
    end
  end

  # Calculates an RFC 2104-compliant HMAC signature.
  class Signature
    SHA256 = OpenSSL::Digest.new('SHA256')

    def initialize(secret)
      @secret = secret
    end

    def sign(message)
      Base64.encode64(OpenSSL::HMAC.digest(SHA256, secret, message)).strip
    end

    def secret
      @secret || raise(ArgumentError, 'Missing secret')
    end
  end

  # Because Ruby's CGI escapes tilde, use a custom escape.
  module Utils
    UNRESERVED = /([^\w.~-]+)/.freeze

    def self.escape(val)
      val.to_s.gsub(UNRESERVED) do
        match = Regexp.last_match[1]
        "%#{match.unpack('H2' * match.bytesize).join('%')}".upcase
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)

    # Common parameters required by all AWS requests.
    #
    # Add other common parameters using `Jeff.params` if required in your
    # implementation.
    base.params(
      'AWSAccessKeyId' => -> { aws_access_key_id },
      'SignatureVersion' => '2',
      'SignatureMethod' => 'HmacSHA256',
      'Timestamp' => -> { Time.now.utc.iso8601 }
    )

    super
  end

  # A reusable HTTP connection.
  def connection
    @connection ||= Excon.new(aws_endpoint, connection_params)
  end

  def connection_params
    @connection_params ||= default_connection_params
  end

  attr_accessor :aws_endpoint

  attr_writer :aws_access_key_id, :aws_secret_access_key

  def aws_access_key_id
    @aws_access_key_id || ENV.fetch('AWS_ACCESS_KEY_ID', nil)
  end

  def aws_secret_access_key
    @aws_secret_access_key || ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
  end

  def proxy=(url)
    connection_params.store(:proxy, url)
  end

  # Generate HTTP request verb methods.
  Excon::HTTP_VERBS.each do |method|
    eval <<-RUBY, binding, __FILE__, __LINE__ + 1
      def #{method}(options = {})                           # def post(options = {})
        options.store(:method, :#{method})                  #   options.store(:method, :post)
        add_md5_digest options                              #   add_md_5_digest_options
        sign options                                        #   sign options
        #{'move_query_to_body options' if method == 'post'} #   move_query_to_body options
        connection.request(options)                         #   connection.request(options)
      end                                                   # end
    RUBY
  end

  private

  def default_connection_params
    {
      headers: { 'User-Agent' => self.class.user_agent },
      expects: 200,
      omit_default_port: true
    }
  end

  def add_md5_digest(options)
    return unless options.key?(:body)

    md5 = Content.new(options[:body]).md5
    query = options[:query] ||= {}
    query.store('ContentMD5Value', md5)
  end

  def sign(options)
    # Build query string.
    query_values = default_query_values.merge(options.fetch(:query, {}))
    query_string = Query.new(query_values).to_s

    # Generate signature.
    signature = Signer
                .new(options[:method], connection.data[:host], options[:path] || connection.data[:path], query_string)
                .sign_with(aws_secret_access_key)

    # Append escaped signature to query.
    options.store(:query, "#{query_string}&Signature=#{Utils.escape(signature)}")
  end

  def move_query_to_body(options)
    return if options[:body]

    options[:headers] ||= {}
    options[:headers].store('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8')
    options.store(:body, options.delete(:query))
  end

  def default_query_values
    self.class.params
        .reduce({}) do |qv, (k, v)|
      v = v.respond_to?(:call) ? instance_exec(&v) : v

      # Ignore keys with nil values
      v.nil? ? qv : qv.update(k => v)
    end
  end

  # Defines class-level methods
  module ClassMethods
    # Gets/updates default request parameters.
    def params(hsh = {})
      (@params ||= {}).update(hsh)
    end

    def user_agent
      @user_agent ||= default_user_agent
    end

    attr_writer :user_agent

    private

    # Amazon recommends to include a User-Agent header with every request to
    # identify the application, its version number, programming language, and
    # host.
    def default_user_agent
      "Peddler/#{Peddler::VERSION} (Language=Ruby; #{Socket.gethostname})"
    end
  end
end
