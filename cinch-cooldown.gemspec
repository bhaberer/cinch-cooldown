# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cinch/cooldown/version'

Gem::Specification.new do |gem|
  gem.name = 'cinch-cooldown'
  gem.version = Cinch::Cooldowns::VERSION
  gem.authors = ['Brian Haberer']
  gem.email = ['bhaberer@gmail.com']
  gem.description = %q(This gem allows you to set a shared timer across plugins that are configured to respect it.)
  gem.summary = %q(Global Cooldown tracker for Cinch Plugins)
  gem.homepage = 'https://github.com/bhaberer/cinch-cooldown'

  gem.files = `git ls-files`.split($/)
  gem.executables = gem.files.grep(/^bin\//).map { |f| File.basename(f) }
  gem.test_files = gem.files.grep(/^(test|spec|features)\//)
  gem.require_paths = ['lib']
  gem.license = 'MIT'
  gem.required_ruby_version = '>= 2.0.0'

  gem.add_development_dependency 'rake', '~> 12.3.3'
  gem.add_development_dependency 'rspec', '~> 3'
  gem.add_development_dependency 'cinch-test', '~> 0.1', '>= 0.1.1'
  gem.add_development_dependency 'codeclimate-test-reporter', '~> 0.4'

  gem.add_dependency 'cinch', '~> 2'
  gem.add_dependency 'time-lord', '~> 1.0', '>= 1.0.1'
end
