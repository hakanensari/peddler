# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'peddler/version'

Gem::Specification.new do |gem|
  gem.name     = 'peddler'
  gem.version  = Peddler::VERSION
  gem.authors  = ['Hakan Ensari']
  gem.email    = ['me@hakanensari.com']
  gem.homepage = 'https://github.com/hakanensari/peddler'
  gem.summary  = 'A Ruby wrapper to the Amazon MWS API'
  gem.license  = 'MIT'

  gem.files = Dir.glob('lib/**/*') + %w[LICENSE README.md]

  gem.add_dependency 'excon', '>= 0.50.0'
  gem.add_dependency 'multi_xml', '>= 0.5.0'

  gem.required_ruby_version = '>= 2.7'
  gem.metadata['rubygems_mfa_required'] = 'true'
end
