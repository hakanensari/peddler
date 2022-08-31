# frozen_string_literal: true

require 'vcr'
require 'yaml'

%w[credentials.yml credentials.example.yml].each do |filename|
  file = File.join(__dir__, filename)
  if File.exist?(file)
    CREDENTIALS = YAML.load_file(file, symbolize_names: true)
    break
  end
end


VCR.configure do |c|
  CREDENTIALS.map(&:values).flatten.each do |value|
    c.filter_sensitive_data('<SCRUBBED>') { value }
  end
end
