# frozen_string_literal: true

require_relative "path_rule"

module Gort
  # Disallow rule.
  class DisallowRule < PathRule
    # @param value [String] the path pattern to disallow.
    def initialize(value)
      super(:disallow, value)
    end
  end
end
