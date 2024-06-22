# frozen_string_literal: true

require_relative "rule"

module Gort
  # User-agent rule.
  class UserAgentRule < Rule
    def initialize(value)
      super(:"user-agent", value)
    end

    PRODUCT_TOKEN_RE = /\A([a-z_-]+|\*)\z/i
    private_constant :PRODUCT_TOKEN_RE

    # Returns +true+ if the value is a valid user agent.
    #
    # A user agent token is a sequence of letters (a—z, A—Z), digits (0—9),
    # underscores (_), or hyphens (-). Alternatively, a single asterisk (*) is also allowed.
    #
    # @return [Boolean]
    #   - +true+ if the value is a valid product token
    #   - +false+ otherwise
    def valid?
      value.match?(PRODUCT_TOKEN_RE)
    end

    # @!group Formatting Methods

    # A human readable representation of the rule.
    #
    # @return [String]
    # @tool
    #   :nocov:
    def inspect
      %(#<#{self.class.name}:#{object_id} "#{value}">)
    end
    # :nocov:

    # Produces a pretty human readable representation of the rule.
    #
    # @param pp [PrettyPrint] pretty printer
    # @return [void]
    # @tool
    #   :nocov:
    def pretty_print(pp)
      pp.text("#{self.class.name}/#{object_id}< #{value} >")
    end
    # :nocov:

    # @!endgroup Formatting Methods
  end
end
