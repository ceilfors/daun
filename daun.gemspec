# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'daun/version'

Gem::Specification.new do |spec|
  spec.name          = "daun"
  spec.version       = Daun::VERSION
  spec.authors       = ["Wisen Tanasa"]
  spec.email         = ["wisen@ceilfors.com"]

  spec.summary       = %q{Expand git branches and tags to a directory}
  spec.description   = 'Daun is useful for source code search like OpenGrok that'\
                       'does not support git branches and tags by default.'
  spec.homepage      = "https://github.com/ceilfors/daun"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'simplecov', '~> 0.11.2'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 0.6.0'
  spec.add_development_dependency 'rubocop', '~> 0.41.1'
end
