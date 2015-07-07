require_relative "lib/connect_client/version"

Gem::Specification.new do |gem|
  gem.name        = "connect_client"
  gem.version     = ConnectClient::VERSION
  gem.authors     = ["Team Connect"]
  gem.email       = "team@getconnect.io"
  gem.homepage    = "https://github.com/getconnect/connect_client-rb"
  gem.summary     = "Connect SDK"
  gem.description = "Ruby Connect SDK for interacting with the Connect API"
  gem.license     = "MIT"

  gem.add_dependency 'json'

  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'eventmachine'
  gem.add_development_dependency 'em-http-request'
  gem.add_development_dependency 'em-synchrony'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
end