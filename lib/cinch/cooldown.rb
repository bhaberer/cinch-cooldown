require 'cinch/cooldown/version'
require 'time-lord'

module Cinch
  module Plugin
    module ClassMethods
      def enforce_cooldown
        hook(:pre, :for => [:match], :method => lambda {|m| cooldown_finished?(m)})
      end

      def reset_cooldown
         # TODO
      end
    end

    def cooldown_finished?(m)
      # return if we don't have a cooldown config
      return true unless shared[:cooldown] && shared[:cooldown][:config]
      synchronize(:cooldown) do
        # return if we don't have a channel (i.e. user is pming the bot)
        return false if m.channel.nil?

        channel = m.channel.name
        user    = m.user.nick

        # Make sure the configuration is sane.
        return true if configuration_broken?(channel)

        # Make sure it's not the first command
        return true if first_run?(channel, user)

        # Check if timers are finished
        return true if cooldowns_finished?(channel, user)

        # Handle unfinished cooldowns here
        m.user.notice cooldown_message(channel, user)
        return false
      end
    end

    def configuration_broken?(channel)
      # return if the config doesn't smell right for this channel
      return true unless shared[:cooldown][:config].key?(channel) &&
                         shared[:cooldown][:config][channel].key?(:global) &&
                         shared[:cooldown][:config][channel].key?(:user)
    end

    def first_run?(channel, user)
      unless shared[:cooldown].key?(channel)
        trigger_cooldown_for(channel, user)
        return true
      end
    end

    def cooldowns_finished?(channel, user)
      # Normal usage stuff starts here, check and see if the channel time is up
      if channel_cooldown_finished?(channel)
        # channel cd is up, check per user by checking if the user's even triggered a cd yet
        if shared[:cooldown][channel].key?(user)
          # User's in the config, check time
          if user_cooldown_finished?(channel, user)
            # Their time's up, run the command
            trigger_cooldown_for(channel, user)
            return true
          end
        else
          # User's not used bot before, run the command
          trigger_cooldown_for(channel, user)
          return true
        end
      end
    end

    def cooldown_message(channel, user)
      message = ['Sorry, you\'ll have to wait']
      unless channel_cooldown_finished?(channel)
        message << TimeLord::Period.new(cooldown_channel_expire_time(channel), Time.now).to_words
        message << 'before I can talk in the channel again, and'
      end
      message << TimeLord::Period.new(cooldown_user_expire_time(channel, user), Time.now).to_words
      message << 'before you can use any commands.'

      return message.join(' ')
    end

    def trigger_cooldown_for(channel, user)
      shared[:cooldown][channel] = { :global => Time.now, user => Time.now }
    end

    def cooldown_channel_expire_time(channel)
      shared[:cooldown][channel][:global] + shared[:cooldown][:config][channel][:global]
    end

    def cooldown_user_expire_time(channel, user)
      shared[:cooldown][channel][user] + shared[:cooldown][:config][channel][:user]
    end

    def user_cooldown_finished?(channel, user)
      cooldown  = shared[:cooldown][:config][channel][:user]
      elapsed   = Time.now - shared[:cooldown][channel][user]
      return cooldown < elapsed
    end

    def channel_cooldown_finished?(channel)
      cooldown  = shared[:cooldown][:config][channel][:global]
      elapsed   = Time.now - shared[:cooldown][channel][:global]
      return cooldown < elapsed
    end
  end
end
