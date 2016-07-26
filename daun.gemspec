# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'daun/version'
require 'rbconfig'

Gem::Specification.new do |spec|
  spec.name          = 'daun'
  spec.version       = Daun::VERSION
  spec.authors       = ['Wisen Tanasa']
  spec.email         = ['wisen@ceilfors.com']

  spec.summary       = 'Expand git branches and tags to a directory'
  spec.description   = 'Daun is a CLI program that will expand git branches and tags to your disk'\
                       ' as directories. Daun will keep the expanded directories in sync whenever there are'\
                       ' new, updated, or deleted tags and branches.'
  spec.homepage      = 'https://github.com/ceilfors/daun'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
                           .reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9'

  spec.add_development_dependency 'bundler',                   '~> 1.11'
  spec.add_development_dependency 'rake',                      '~> 10.0'
  spec.add_development_dependency 'rspec',                     '~> 3.0'
  spec.add_development_dependency 'simplecov',                 '~> 0.11', '>= 0.11.2'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 0.6',  '>= 0.6.0'
  spec.add_development_dependency 'rubocop',                   '~> 0.41', '>= 0.41.1'
  spec.add_development_dependency 'rspec_junit_formatter',     '~> 0.2',  '>= 0.2.2'
  spec.add_development_dependency 'yard',                      '~> 0.9',  '>= 0.9.4'
  spec.add_development_dependency 'redcarpet',                 '~> 3.3',  '>= 3.3.4'

  spec.add_runtime_dependency     'json',                      '< 2' # json 2 requires ruby 2
  spec.add_runtime_dependency     'thor',                      '~> 0.19', '>= 0.19.1'
  spec.add_runtime_dependency     'logging',                   '~> 2.0'

  if RbConfig::CONFIG['host_os'] =~ /solaris|bsd|linux/
    spec.add_runtime_dependency     'rugged',                    '~> 0.21'
  else
    # Can't pull 0.24.0 yet because this depends on the libgit2 version installed locally
    spec.add_development_dependency 'rugged',                    '~> 0.23.0'
  end
end
