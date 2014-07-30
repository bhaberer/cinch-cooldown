# -*- coding: utf-8 -*-
module Cinch
  # An alteration to the Plugin Module to allow for configurable cooldowns.
  module Plugin
    # Add the pre hook to all messages triggered
    module ClassMethods
      def enforce_cooldown
        hook(:pre,
             for: [:match],
             method: ->(m) { Cooldowns.finished?(m, shared[:cooldown], @bot) })
      end
    end
  end
end
