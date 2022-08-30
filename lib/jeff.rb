# frozen_string_literal: true

require 'base64'
require 'openssl'
require 'time'
require 'uri'

require 'http'
require 'multi_xml'

require 'peddler/version'

# XML adapter
module XMLAdapter
  def self.encode(_)
    raise
  end

  def self.decode(str)
    MultiXml.parse(str)
  end
end

HTTP::MimeType.register_adapter 'text/xml', XMLAdapter

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
    @connection ||= HTTP::Client.new.headers('User-Agent' => self.class.user_agent)
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
    uri = URI(url)
    @connection = connection.via(uri.hostname, uri.port, uri.user, uri.password)
  end

  # Generate HTTP request verb methods.
  %w[get post].each do |verb|
    eval <<-RUBY, binding, __FILE__, __LINE__ + 1
      def #{verb}(options = {})                          # def post(options = {})
        options = options.dup                            #   options = options.dup
        uri = URI(aws_endpoint)                          #   uri = URI(aws_endpoint)
        options = add_default_query_values(options)      #   options = add_default_query_values(options)
        options = add_md5_digest(options)                #   options = add_md_5_digest(options)
        options = sign('#{verb}', uri, options)          #   options = sign(options)
        options = move_query_to_body('#{verb}', options) #   options = move_query_to_body('post', options)

        connection.#{verb}(uri, options)                 #   connection.post(aws_endpoint, options)
      end                                                # end
    RUBY
  end

  def add_default_query_values(options)
    options[:params] = default_query_values.merge(options.fetch(:params, {}))
    options
  end

  def add_md5_digest(options)
    options = options.dup
    return options unless options.key?(:body)

    md5 = Content.new(options[:body]).md5
    params = options[:params] ||= {}
    params.store('ContentMD5Value', md5)

    options
  end

  def sign(verb, uri, options)
    options = options.dup

    # Build query string.
    params = options[:params]
    query_string = Query.new(params).to_s

    # Generate signature.
    signature = Signer
                .new(verb, uri.host, uri.path, query_string)
                .sign_with(aws_secret_access_key)

    # Append escaped signature to params.
    params.store('Signature', signature)
    # options.store(:params, "#{query_string}&Signature=#{Utils.escape(signature)}")

    options
  end

  def move_query_to_body(verb, options)
    options = options.dup

    return options unless verb == 'post'
    return options if options[:body]

    options[:headers] ||= {}
    options[:headers].store('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8')
    options.store(:body, Query.new(options.delete(:params)).to_s)

    options
  end

  private

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
