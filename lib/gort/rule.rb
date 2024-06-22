# frozen_string_literal: true

module Gort
  # Generic rule.
  # This represents an entry that looks like a valid rule but otherwise doesn't
  # have a more specialized implementation.
  class Rule
    # @param name [Symbol] The name of the rule.
    # @param value [String] The value of the rule.
    def initialize(name, value)
      @name = name.downcase.to_sym
      @value = value
    end

    # The name of the rule.
    # @return [Symbol]
    attr_reader :name

    # The value of the rule.
    # @return [String]
    attr_reader :value

    # @!group Formatting Methods

    # A human readable representation of the rule.
    #
    # @return [String]
    # @tool
    #   :nocov:
    def inspect
      %(#<#{self.class.name}:#{object_id} "#{name}", "#{value}">)
    end
    # :nocov:

    # Produces a pretty human readable representation of the rule.
    #
    # @param pp [PrettyPrint] pretty printer
    # @return [void]
    # @tool
    #   :nocov:
    def pretty_print(pp)
      pp.text("#{self.class.name}/#{object_id}< #{name.inspect}, #{value} >")
    end
    # :nocov:

    # @!endgroup Formatting Methods
  end
end
