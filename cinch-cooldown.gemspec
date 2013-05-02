# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cinch-cooldown/version'

Gem::Specification.new do |gem|
  gem.name          = "cinch-cooldown"
  gem.version       = Cinch::Cooldown::VERSION
  gem.authors       = ["Brian Haberer"]
  gem.email         = ["bhaberer@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = "https://github.com/bhaberer/cinch-cooldown"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'cinch-toolbox'
end
