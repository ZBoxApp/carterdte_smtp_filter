# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carterdte_smtp_filter/version'

Gem::Specification.new do |spec|
  spec.name          = "carterdte_smtp_filter"
  spec.version       = CarterdteSmtpFilter::VERSION
  spec.authors       = ["Patricio Bruna"]
  spec.email         = ["pbruna@gmail.com"]
  spec.summary       = "Postfix SMTP Filter to parse DTE files to CarterDTE Platform"
  spec.description   = "Description - #{spec.summary}"
  spec.homepage      = "https://github.com/ZBoxApp/carterdte_smtp_filter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'mail', "~> 2.6"
  spec.add_dependency "midi-smtp-server", "~> 2.0"
  spec.add_dependency 'xml-simple', "~> 1.1"
  spec.add_dependency "rest-client", "~> 1.7"
  
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.4"
  spec.add_development_dependency "guard", "~> 2.12"
  spec.add_development_dependency "guard-minitest", "~> 2.4"
  spec.add_development_dependency "minitest-reporters", "~> 1.0"
  spec.add_development_dependency "sinatra", "~> 1.4"
  spec.add_development_dependency "webmock", "~> 1.20"
end
