require 'spec_helper'

class MyPlugin
  include Cinch::Plugin
  enforce_cooldown
  match(/thing/)
  def execute(m)
    m.reply 'OMG'
  end
end

def bot_for_cooldowns(global: 10, user: 0, channel: 'foo')
  Cinch::Test::MockBot.new do
    configure do |c|
      c.nick = 'testbot'
      c.server = nil
      c.channels = ['channel']
      c.reconnect = false
      c.plugins.plugins = [MyPlugin]
      c.shared[:cooldown] = { config: { channel.to_sym => { global: global, user: user } } }
    end
  end
end

describe Cinch::Cooldowns do
  include Cinch::Test

  after(:each) do
    Cinch::Plugin::Cooldowns.purge!
  end

  let(:bot) { bot_for_cooldowns }

  context 'when sending the bot a pm' do
    it 'do not trigger cooldowns' do
      get_replies(make_message(bot, "!thing"))
      reply = get_replies(make_message(bot, "!thing")).first.text
      expect(reply).to match('OMG')
    end
  end

  context 'when using global cooldowns' do
    it 'allows a global cooldown between responses in channel' do
      get_replies(make_message(bot, "!thing", channel: '#foo'))
      reply = get_replies(make_message(bot, "!thing", channel: '#foo')).first.text
      expect(reply).to match(/Sorry, cooldown is in effect: \d+ seconds from now/)
    end

    it 'allows responses after the global cooldown expires' do
      bot = bot_for_cooldowns(global: 5, user: 5)
      get_replies(make_message(bot, "!thing", channel: '#foo'))
      sleep 7
      reply = get_replies(make_message(bot, "!thing", channel: '#foo')).first.text
      expect(reply).to eq('OMG')
    end

    it 'triggers for other users if the global cooldown is finished' do
      bot = bot_for_cooldowns(global: 0, user: 20)
      reply_a = get_replies(make_message(bot, "!thing", channel: '#foo', nick: 'test1')).first.text
      expect(reply_a).to eq('OMG')
      sleep 1
      reply_b = get_replies(make_message(bot, "!thing", channel: '#foo', nick: 'test2')).first.text
      expect(reply_b).to eq('OMG')
    end

    it 'does not trigger for other users if the global cooldown is not finished' do
      bot = bot_for_cooldowns(global: 10, user: 20)
      reply_good = get_replies(make_message(bot, "!thing", channel: '#foo', nick: 'test1')).first.text
      expect(reply_good).to eq('OMG')
      reply_cool = get_replies(make_message(bot, "!thing", channel: '#foo', nick: 'test2')).first.text
      expect(reply_cool).not_to eq('OMG')
    end
  end

  context 'when using user cooldowns' do
    it 'does not allow users to use commands in the period between cooldowns' do
      bot = bot_for_cooldowns(global: 5, user: 10)
      get_replies(make_message(bot, "!thing", channel: '#foo'))
      sleep 7
      reply = get_replies(make_message(bot, "!thing", channel: '#foo')).first.text
      expect(reply).to match(/Sorry, cooldown is in effect: \d+ seconds from now before you can use/)
    end

    it 'allows users to use commands after their cooldown period ends' do
      bot = bot_for_cooldowns(global: 5, user: 10)
      get_replies(make_message(bot, "!thing", channel: '#foo'))
      sleep 12
      reply = get_replies(make_message(bot, "!thing", channel: '#foo')).first.text
      expect(reply).to eq('OMG')
    end
  end

  it 'manages mutiple users incurring simultaneous cooldowns' do
    bot = bot_for_cooldowns(global: 5, user: 10)
    get_replies(make_message(bot, "!thing", channel: '#foo'))
    get_replies(make_message(bot, "thing",  channel: '#foo'))
    sleep 6
    get_replies(make_message(bot, "!thing", channel: '#foo', nick: 'george'))
    sleep 5
    expect(get_replies(make_message(bot, "!thing", channel: '#foo')).first.text)
      .to eq('OMG')
  end

  context 'when configuration issues arise' do
    it 'does not trigger if the config for the current channel does not exist' do
      bot = bot_for_cooldowns(global: 5, user: 10)
      get_replies(make_message(bot, "!thing", channel: '#bar'))
      expect(get_replies(make_message(bot, "!thing", channel: '#bar')).first.text)
        .to eq('OMG')
    end
  end
end
