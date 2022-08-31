#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

FileUtils.rm_rf('lib')

FileUtils.rm_rf('selling-partner-api-models')
`git clone git@github.com:amzn/selling-partner-api-models.git`

specs = Dir.glob('selling-partner-api-models/models/**/*.json').reduce({}) do |hsh, file|
  spec = file.split('/')[-2]
  hsh.merge(spec => file)
end
threads = []
specs.each_value do |file|
  threads << Thread.new do
    `openapi-generator generate --global-property apis \
                                  --global-property apiDocs=false \
                                  --global-property apiTests=false \
                                  --additional-properties moduleName=SellingPartner \
                                  --skip-validate-spec \
                                  --generator-name ruby \
                                  --template-dir templates \
                                  --input-spec #{file}`
  end
end
threads.each(&:join)

Dir.glob('lib/selling_partner/api/*').each do |file|
  FileUtils.mv(file, file.gsub(%r{[/_]api}, ''))
end
FileUtils.rmdir('lib/selling_partner/api')

FileUtils.rm_rf('selling-partner-api-models')
