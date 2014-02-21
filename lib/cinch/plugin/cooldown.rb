# -*- coding: utf-8 -*-
module Cinch
  module Plugin
    # An alteration to the Plugin Module to allow for configurable cooldowns.
    class Cooldown
      attr_accessor :time, :duration, :expires_at

      def initialize(duration, time = Time.now)
        @time = time
        @duration = duration
        @expires_at = @time + @duration
      end

      def time_till_expire_in_words
        return 'until right now' if (expires_at - Time.now) < 0
        TimeLord::Period.new(expires_at, Time.now).to_words
      end

      def time_till_expire
        period = @expires_at - Time.now
        return 0 if period < 0
        period
      end

      def cooled_down?
        time_till_expire.zero?
      end
    end
  end
end
