# frozen_string_literal: true

require_relative "rule_set"

module Gort
  # An access group
  class Group < RuleSet
    # Is this group valid?
    #
    # A valid group has at least one valid user-agent rule.
    #
    # @return [Boolean]
    # @see UserAgentRule#valid?
    def valid?
      @valid ||=
        rules.any? { |rule| rule.is_a?(UserAgentRule) && rule.valid? }
    end

    # Does this group apply to this specific user agent?
    #
    # This performa user agent matcchign acording to the RFC.
    #
    # @param user_agent [String]
    # @return [Boolean]
    def apply?(user_agent)
      apply_to_all? || user_agent.match?(user_agent_regexp)
    end

    # @!group Formatting Methods

    # A human readable representation of the group.
    #
    # @return [String]
    # @tool
    #   :nocov:
    def inspect
      "#<#{self.class.name}:#{object_id} #{rules.inspect}>"
    end
    # :nocov:

    # Produces a pretty human readable representation of the group.
    #
    # @param pp [PrettyPrint] pretty printer
    # @return [void]
    # @tool
    #   :nocov:
    def pretty_print(pp)
      pp.text("#{self.class.name}/#{object_id}")
      pp.group(1, "[", "]") do
        pp.breakable("")
        pp.seplist(rules) do |rule|
          pp.pp(rule)
        end
        pp.breakable("")
      end
    end
    # :nocov:

    # @!endgroup Formatting Methods

    private

    # Does this rule apply to all user agents?
    #
    # Effectively, is this rule is a `*` rule.
    #
    # @return [Boolean]
    def apply_to_all?
      @apply_to_all ||= rules.any? { |rule| rule.is_a?(UserAgentRule) && rule.valid? && rule.value == "*" }
    end

    # A compiled Regexp that mathes all user agents in this group.
    #
    # @return [Regexp]
    def user_agent_regexp
      @user_agent_regexp ||=
        begin
          specific_user_agent_rules = rules.select { |rule|
            rule.is_a?(UserAgentRule) && rule.valid? && (rule.value != "*")
          }
          Regexp.new(specific_user_agent_rules.map { Regexp.escape(_1.value) }.join("|"), Regexp::IGNORECASE)
        end
    end
  end
end
