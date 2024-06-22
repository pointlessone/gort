# frozen_string_literal: true

module Gort
  # Abstract rule set.
  #
  # @abstract
  class RuleSet
    # @param rules [Array<Group, UserAgentRule, AllowRule, DisallowRule, Rule, InvalidLine>]
    #    The rules. Or invalid lines.
    def initialize(*rules)
      @rules = rules.flatten.freeze
    end

    # Rules in this set
    # @return [Array<Group, UserAgentRule, AllowRule, DisallowRule, Rule, InvalidLine>]
    attr_reader :rules

    # Make a new set by mergin this one with another.
    # @param other [RuleSet]
    # @return [RuleSet]
    def merge(other)
      self.class.new(rules + other.rules)
    end
  end
end
