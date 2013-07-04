require 'spec_helper'

class MyPlugin
  include Cinch::Plugin

  enforce_cooldown

  match /thing/
  def execute(m)
    m.reply 'OMG'
  end
end

def bot_for_cooldowns(global = 10, user = 0)
  @bot = Cinch::Test::MockBot.new do
           configure do |c|
             c.nick = 'testbot'
             c.server = nil
             c.channels = ['foo']
             c.reconnect = false
             c.plugins.plugins = [MyPlugin]
             c.shared[:cooldown] = { :config => { '#foo' => { :global => global, :user => user } } }
           end
         end
end

describe Cinch::Cooldown do
  include Cinch::Test

  it 'should not trigger cooldowns on private messages' do
    @bot = bot_for_cooldowns(10)
    get_replies(make_message(@bot, "!thing"))
    get_replies(make_message(@bot, "!thing")).first.text.
      should match "OMG"
  end

  it 'should allow plugins to mandate a global cooldown between responses in channel' do
    @bot = bot_for_cooldowns(10)
    get_replies(make_message(@bot, "!thing", channel: '#foo'))
    get_replies(make_message(@bot, "!thing", channel: '#foo')).first.text.
      should match(/Sorry, you'll have to wait \d+ seconds from now before I can talk/)
  end

  it 'should allow plugins allow responses after the global cooldown' do
    @bot = bot_for_cooldowns(5)
    get_replies(make_message(@bot, "!thing", channel: '#foo'))
    sleep 5
    get_replies(make_message(@bot, "!thing", channel: '#foo')).first.text.
      should == 'OMG'
  end

  it 'should allow plugins to mandate a minimum time between responses in channel' do
    @bot = bot_for_cooldowns(5, 10)
    get_replies(make_message(@bot, "!thing", channel: '#foo'))
    sleep 6
    get_replies(make_message(@bot, "!thing", channel: '#foo')).first.text.
      should match(/Sorry, you'll have to wait \d+ seconds from now before you can use/)
  end

  it 'should allow plugins to mandate a minimum time between responses in channel' do
    @bot = bot_for_cooldowns(5, 10)
    get_replies(make_message(@bot, "!thing", channel: '#foo'))
    sleep 10
    get_replies(make_message(@bot, "!thing", channel: '#foo')).first.text.
      should == 'OMG'
  end

  it 'should not trigger if the config for the current channel does not exist' do
    @bot = bot_for_cooldowns(5, 10)
    get_replies(make_message(@bot, "!thing", channel: '#bar'))
    get_replies(make_message(@bot, "!thing", channel: '#bar')).first.text.
      should == 'OMG'
  end

  it 'should trigger for other users if the global cooldown is not finished' do
    @bot = bot_for_cooldowns(10, 20)
    get_replies(make_message(@bot, "!thing", channel: '#foo', nick: 'test1')).first.text.
      should == 'OMG'
    get_replies(make_message(@bot, "!thing", channel: '#foo', nick: 'test2')).first.text.
      should_not == 'OMG'
  end
end
