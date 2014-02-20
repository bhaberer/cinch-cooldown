# -*- coding: utf-8 -*-
module Cinch
  module Plugin
    # An alteration to the Plugin Module to allow for configurable cooldowns.
    class Cooldown
      include Cinch::Plugin

      @cooldown_state_data = {}
      attr_accessor :cooldown_state_data

      def self.finished?(m, shared, bot)
        @cooldown_state_data = shared
        # return if we don't have a cooldown config
        return true unless @cooldown_state_data &&
                           @cooldown_state_data.key?(:config)
        bot.synchronize(:cooldown) do
          # return if we don't have a channel (i.e. user is pming the bot)
          return true if m.channel.nil?

          return true if cool?(m.channel.name, m.user.nick)

          # Handle unfinished cooldowns here
          m.user.notice message(m.channel.name, m.user.nick)
          false
        end
      end

      def self.cool?(channel, user)
        # Make sure the configuration is sane.
        return true if config_broken?(channel) ||
                       # Make sure it's not the first command
                       first_run?(channel, user) ||
                       # Check if timers are finished
                       cooldowns_finished?(channel, user)

        false
      end

      def self.config_broken?(channel)
        # return if the config doesn't smell right for this channel
        return true unless config.key?(channel) &&
                           config_for(channel).key?(:global) &&
                           config_for(channel).key?(:user)
        false
      end

      def self.config
        @cooldown_state_data[:config]
      end

      def self.config_for(chan)
        config[chan]
      end

      def self.first_run?(channel, user)
        unless @cooldown_state_data.key?(channel)
          warn '[[ Initializing Cooldown Data ]]'
          trigger_cooldown_for(channel, user)
          true
        end
      end

      def self.cooldowns_finished?(channel, user)
        if channel_cooled_down?(channel) && user_cooled_down?(channel, user)
          # Their time's up, or they've not used bot before, run the command
          trigger_cooldown_for(channel, user)
          return true
        end
        false
      end

      def self.message(channel, user)
        message = ['Sorry, you\'ll have to wait']
        unless channel_cooled_down?(channel)
          message << TimeLord::Period.new(channel_expire_time(channel),
                                          Time.now).to_words
          message << 'before I can talk in the channel again, and'
        end
        message << TimeLord::Period.new(user_expire_time(channel, user),
                                        Time.now).to_words
        message << 'before you can use any commands.'

        message.join(' ')
      end

      def self.trigger_cooldown_for(channel, user)
        @cooldown_state_data[channel] ||= {}
        @cooldown_state_data[channel][:global] = Time.now
        @cooldown_state_data[channel][user] = Time.now
        # @cooldown_state_data[channel] = { :global => Time.now,
        #                                   user    => Time.now }
        warn "[[ Cooldown Triggered for user: #{user} ]]"
      end

      def self.channel_expire_time(channel)
        global_cooldown_for(channel) + config_for(channel)[:global]
      end

      def self.user_expire_time(channel, user)
        user_cooldown_for(channel, user) + config_for(channel)[:user]
      end

      def self.user_cooled_down?(channel, user)
        return true if config_for(channel).nil?
        cooldown  = config_for(channel)[:user]
        elapsed   = Time.now - user_cooldown_for(channel, user)
        cooldown <= elapsed
      end

      def self.channel_cooled_down?(channel)
        cooldown  = config_for(channel)[:global]
        elapsed   = Time.now - global_cooldown_for(channel)
        cooldown <= elapsed
      end

      def self.global_cooldown_for(chan)
        @cooldown_state_data[chan][:global] ||= Time.now
      end

      def self.user_cooldown_for(chan, nick)
        @cooldown_state_data[chan][nick] || Time.now
      end
    end
  end
end
