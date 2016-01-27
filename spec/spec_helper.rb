require 'coveralls'
require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter]
)
SimpleCov.start

require 'cinch/cooldown'
require 'cinch/test'
