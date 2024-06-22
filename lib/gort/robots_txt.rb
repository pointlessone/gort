# frozen_string_literal: true

module Gort
  # Represents a robots.txt file.
  class RobotsTxt
    ROBOTS_TXT_PATH = "/robots.txt"
    private_constant :ROBOTS_TXT_PATH

    def initialize(rules)
      @rules = rules
    end

    # @return [Array<Rule, Group, InvalidLine>]
    attr_reader :rules

    # Is this path allowed for the given user agent?
    #
    # @param user_agent [String]
    # @param path_and_query [String]
    # @return [Boolean]
    # @see PathRule#match
    # @see #disallow?
    def allow?(user_agent, path_and_query)
      return true if path_and_query == ROBOTS_TXT_PATH

      top_match =
        matches(user_agent, path_and_query)
        .compact
        # This is an arcane bit.
        # The rules are reverse sorted by match length (i.e. longest first),
        # and then by class name using the fact that allow goes before disallow.
        # This is the rule precedence order defined in the RFC.
        .min_by { |(match_length, rule)| [-match_length, rule.class.name] }

      # Allow if there is no match or the top match is an allow rule.
      top_match.nil? || top_match.last.is_a?(AllowRule)
    end

    # Is this path disallowed for the given user agent?
    #
    # @param user_agent [String]
    # @param path_and_query [String]
    # @return [Boolean]
    # @see PathRule#match
    # @see #allow?
    def disallow?(user_agent, path_and_query)
      !allow?(user_agent, path_and_query)
    end

    # @!group Formatting Methods

    # A human readable representation of the robots.txt.
    #
    # @return [String]
    # @tool
    #   :nocov:
    def inspect
      "#<#{self.class.name}:#{object_id} #{rules.inspect}>"
    end
    # :nocov:

    # Produces a pretty human readable representation of the robots.txt.
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

    def matches(user_agent, path)
      # @type var groups: Array<Group>
      groups = rules.select { |rule| rule.is_a?(Group) && rule.valid? && rule.apply?(user_agent) }
      groups.flat_map do |group|
        group.rules.filter_map do |rule|
          next unless rule.is_a?(PathRule)

          rule.match(path)
        end
      end
    end
  end
end
