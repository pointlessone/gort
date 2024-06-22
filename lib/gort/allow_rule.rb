# frozen_string_literal: true

require_relative "path_rule"

module Gort
  # Allow rule.
  class AllowRule < PathRule
    # @param value [String] the path pattern to allow.
    def initialize(value)
      super(:allow, value)
    end
  end
end
