require 'spec_helper'

class MyPlugin
  include Cinch::Plugin

  enforce_cooldown

  match(/thing/)
  
  def execute(m)
    m.reply 'OMG'
  end
end

def bot_for_cooldowns(global = 10, user = 0)
  Cinch::Test::MockBot.new do
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

describe Cinch::Cooldowns do
  include Cinch::Test

  after(:each) do
    Cinch::Plugin::Cooldowns.purge!
  end

  it 'should not trigger cooldowns on private messages' do
    bot = bot_for_cooldowns(10)
    get_replies(make_message(bot, "!thing"))
    expect(get_replies(make_message(bot, "!thing")).first.text)
      .to match('OMG')
  end

  it 'should allow plugins to mandate a global cooldown between responses in channel' do
    bot = bot_for_cooldowns(10)
    get_replies(make_message(bot, "!thing", channel: '#foo'))
    expect(get_replies(make_message(bot, "!thing", channel: '#foo')).first.text)
      .to match(/Sorry, cooldown is in effect: \d+ seconds from now before/)
  end

  it 'should allow plugins allow responses after the global cooldown' do
    bot = bot_for_cooldowns(5, 5)
    get_replies(make_message(bot, "!thing", channel: '#foo'))
    sleep 7
    expect(get_replies(make_message(bot, "!thing", channel: '#foo')).first.text)
      .to eq('OMG')
  end

  it 'should allow plugins to mandate a minimum time between responses in channel' do
    bot = bot_for_cooldowns(5, 10)
    get_replies(make_message(bot, "!thing", channel: '#foo'))
    sleep 7
    expect(get_replies(make_message(bot, "!thing", channel: '#foo')).first.text)
      .to match(/Sorry, cooldown is in effect: \d+ seconds from now before you can use/)
  end

  it 'should allow plugins to mandate a minimum time between responses in channel' do
    bot = bot_for_cooldowns(5, 10)
    get_replies(make_message(bot, "!thing", channel: '#foo'))
    sleep 12
    expect(get_replies(make_message(bot, "!thing", channel: '#foo')).first.text)
      .to eq('OMG')
  end

  it 'should aplugins to mandate a minimum time between responses in channel' do
    bot = bot_for_cooldowns(5, 10)
    get_replies(make_message(bot, "!thing", channel: '#foo'))
    get_replies(make_message(bot, "thing",  channel: '#foo'))
    sleep 6
    get_replies(make_message(bot, "!thing", channel: '#foo', nick: 'george'))
    sleep 5
    expect(get_replies(make_message(bot, "!thing", channel: '#foo')).first.text)
      .to eq('OMG')
  end

  it 'should not trigger if the config for the current channel does not exist' do
    bot = bot_for_cooldowns(5, 10)
    get_replies(make_message(bot, "!thing", channel: '#bar'))
    expect(get_replies(make_message(bot, "!thing", channel: '#bar')).first.text)
      .to eq('OMG')
  end

  it 'should trigger for other users if the global cooldown is finished' do
    bot = bot_for_cooldowns(0, 20)
    expect(get_replies(make_message(bot, "!thing", channel: '#foo', nick: 'test1')).first.text)
      .to eq('OMG')
    sleep 1
    expect(get_replies(make_message(bot, "!thing", channel: '#foo', nick: 'test2')).first.text)
      .to eq('OMG')
  end
  it 'should trigger for other users if the global cooldown is finished' do
    bot = bot_for_cooldowns(10, 20)
    expect(get_replies(make_message(bot, "!thing", channel: '#foo', nick: 'test1')).first.text)
      .to eq('OMG')
    expect(get_replies(make_message(bot, "!thing", channel: '#foo', nick: 'test2')).first.text)
      .not_to eq('OMG')
  end
end
