# -*- coding: utf-8 -*-
module Cinch
  module Plugin
    # Class for managing the cooldown objects.
    module Cooldowns
      include Cinch::Plugin

      @cooldowns = {}
      @config = nil

      # Main method called by the hook
      def self.finished?(m, shared, bot)
        return unless shared.is_a?(Hash)
        @config     = shared[:config]
        @cooldowns  = shared[:cooldowns] if shared.key?(:cooldowns)

        # Don't run if we there's no cooldown config
        return true unless @config

        bot.synchronize(:cooldown) do
          # Avoid cooldown if we don't have a channel
          #   (i.e. user is pming the bot)
          return true if m.channel.nil?

          clean_expired_cooldowns(m.channel.name)

          # return true if the cooldowns have expired
          return true if cool?(m.channel.name, m.user.nick)

          # Otherwise message the user about unfinished cooldowns
          m.user.notice message(m.channel.name, m.user.nick)

          # and return false so the command gets dropped by the hook
          false
        end
      end

      # Main cooldown data check
      def self.cool?(channel, user)
        # Make sure the configuration is sane.
        return true if config_broken?(channel) ||
                       # Make sure it's not the first command
                       first_run?(channel, user) ||
                       # Check if timers are finished
                       cooldowns_finished?(channel, user)

        # Otherwise trigger cooldown
        false
      end

      def self.config_broken?(channel)
        # return true if the config doesn't have needed info this channel
        return true unless @config.key?(channel) &&
                           config_for(channel).key?(:global) &&
                           config_for(channel).key?(:user)
        # otherwise abort cooldown enforcement
        false
      end

      def self.config_for(chan)
        @config[chan]
      end

      def self.first_run?(channel, user)
        unless @cooldowns.key?(channel)
          trigger_cooldown_for(channel, user)
          return true
        end
        false
      end

      def self.purge!
        @cooldowns = {}
      end

      def self.cooldowns_finished?(channel, user)
        # Chuck all the cooldowns that have expired
        clean_expired_cooldowns(channel)

        # if the channel's cooldown is up
        if @cooldowns[channel][:global].nil?
          # And their cd's up, or they've not used bot before, run the command
          if @cooldowns[channel][user].nil?
            # trigger a new cooldown
            trigger_cooldown_for(channel, user)
            # and run the command
            return true
          end
        end
        false
      end

      def self.clean_expired_cooldowns(channel)
        return unless @cooldowns.key?(channel)
        @cooldowns[channel].each_pair do |key, cooldown|
          @cooldowns[channel].delete(key) if cooldown.cooled_down?
        end
      end

      def self.message(channel, user)
        cds = []
        if @cooldowns[channel].key?(:global)
          chan_exp = @cooldowns[channel][:global].time_till_expire_in_words
          cds << "#{chan_exp} before I can talk in the channel again"
        elsif @cooldowns[channel].key?(user)
          user_exp = @cooldowns[channel][user].time_till_expire_in_words
          cds << "#{user_exp} before you can use any commands"
        end
        ['Sorry, cooldown is in effect:', cds.join(', and ')].join(' ')
      end

      def self.trigger_cooldown_for(channel, user)
        # Make sure the channel array has been init
        @cooldowns[channel] ||= {}

        # Create a cooldown for the channel
        @cooldowns[channel][:global] =
          Cooldown.new(@config[channel][:global])
        # Create a cooldown for the user
        @cooldowns[channel][user] =
          Cooldown.new(@config[channel][:user])

        warn "[[ Cooldown Triggered for user: #{user} ]]"
      end
    end
  end
end
