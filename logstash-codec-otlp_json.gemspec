Gem::Specification.new do |s|
  s.name          = 'logstash-codec-otlp_json'
  s.version       = '0.2.0'
  s.licenses      = ['Apache-2.0']
  s.summary       = 'Logstash Codec Plugin for OTLP/JSON'
  s.description   = 'Reads OTLP/JSON formatted content, creating one event per log record.'
  s.homepage      = 'https://github.com/yesmarket/logstash-codec-otlp_json'
  s.authors       = ['Ryan Bartsch']
  s.email         = 'rbartsch@yandex.com'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "codec" }

  # Gem dependencies
  s.add_runtime_dependency 'logstash-core-plugin-api', "~> 2.0"
  s.add_runtime_dependency 'logstash-codec-json'
  s.add_development_dependency 'logstash-devutils'
end
