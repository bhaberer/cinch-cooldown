# Cinch::Cooldown

[![Gem Version](https://badge.fury.io/rb/cinch-cooldown.png)](http://badge.fury.io/rb/cinch-cooldown)
[![Dependency Status](https://gemnasium.com/bhaberer/cinch-cooldown.png)](https://gemnasium.com/bhaberer/cinch-cooldown)
[![Build Status](https://travis-ci.org/bhaberer/cinch-cooldown.png?branch=master)](https://travis-ci.org/bhaberer/cinch-cooldown)
[![Coverage Status](https://coveralls.io/repos/bhaberer/cinch-cooldown/badge.png?branch=master)](https://coveralls.io/r/bhaberer/cinch-cooldown?branch=master)
[![Code Climate](https://codeclimate.com/github/bhaberer/cinch-cooldown.png)](https://codeclimate.com/github/bhaberer/cinch-cooldown)

This library is used to add a global cooldown so that users are prevented from spamming the
channel.

## Installation

Add this line to your application's Gemfile:

    gem 'cinch-cooldown'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cinch-cooldown

## Usage

Configuration Steps:

1. You need to add the configuration to your bot in the config block. You will need to add
config info for every channel the bot is in that you want a cooldown. The `:global` is how
many seconds the bot will wait before listening to a command that prints something to the
channel, while the `:user` directive is how long. Currently the gem is simple and assumes
that the user timer will be greater than the global timer.

    c.shared[:cooldown] = { :config => { '#bottest' => { :global => 10
                                                         :user   => 20 } }

2. If you are using this with my plugins, things should just work. However if you want to use
this with your own plugins, you need to add a `require cinch/cooldown` to the top of said
plugin, and an `enforce_cooldown` to the plugin after the `include Cinch::Plugin` line.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
