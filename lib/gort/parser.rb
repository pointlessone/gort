# frozen_string_literal: true

require_relative "invalid_line"
require_relative "rule"
require_relative "user_agent_rule"
require_relative "allow_rule"
require_relative "disallow_rule"
require_relative "rule_set"
require_relative "group"
require_relative "robots_txt"

module Gort
  # robots.txt parser. It implements the parsing logic according to RFC 9309, including errata.
  class Parser
    # You may get this error if the input does not look like a text file.
    class BinaryInputError < Error; end

    # You may get this error if the input looks like a text file but its encoding is invalid.
    class InvalidEncodingError < Error; end

    UTF_8_BOM = "\ufeff"
    private_constant :UTF_8_BOM

    # @param input [String] The robots.txt content to parse. It must be encoded in UTF-8 or compatible encoding.
    def initialize(input)
      @input = detect_and_fix_encoding(input).then { |string| strip_bom(string) }
    end

    # RFC does not explicitly define the generic rule name syntax. It only defines that it has to be case-insensitive.
    # It also provides a few pre-defined rule names such as User-Agent, Allow, and Disallow.
    # Things that might be different from the RFC intention:
    # - The rule name must start with a letter. RFC might allow other characters.
    # - The rule name might contain underscores. RFC doesn't mention underscores.
    # - The rule name might contain digits. RFC doesn't mention digits, either.
    #
    # This is only used for plausible rule detection.
    RULE_KEY = /\A[a-z][a-z0-9_-]*\s*:/i
    private_constant :RULE_KEY

    # Actually parse the file.
    #
    # @return [Gort::RobotsTxt]
    def parse
      content_lines =
        input.lines.map { |line|
          line.split("#", 2).first.strip
        }
        .reject(&:empty?)

      rules = content_lines.map { |line| parse_line(line) }
      grouped_rules, standalone_rules = partition_rules(rules)
      groups = group_rules(grouped_rules)

      RobotsTxt.new(groups + standalone_rules)
    end

    private

    # @return [String]
    attr_reader :input

    # @param string [String]
    # @return [String]
    def detect_and_fix_encoding(string)
      string.encode(Encoding::UTF_8)
    rescue EncodingError
      require "rchardet"
      result = CharDet.detect(string)
      raise BinaryInputError, "Input does not look like text" if result["encoding"].nil? || result["confidence"] < 0.25

      begin
        string
          .dup
          .force_encoding(result["encoding"])
          .encode(Encoding::UTF_8)
      rescue EncodingError
        raise InvalidEncodingError, "Input string looks like text but its encoding is invalid."
      end
    end

    # @param string [String]
    # @return [String]
    def strip_bom(string)
      if string[0] == UTF_8_BOM
        string[1..] # Remove BOM
      else
        string
      end
    end

    # @param line [String]
    # @return [UserAgentRule, AllowRule, DisallowRule, Rule, InvalidLine]
    def parse_line(line)
      if line.match?(RULE_KEY)
        # @type var key: String
        # @type var value: String
        key, value = line.split(":", 2).map(&:strip)
        case key.downcase
        when "user-agent"
          UserAgentRule.new(value)
        when "allow"
          AllowRule.new(value)
        when "disallow"
          DisallowRule.new(value)
        else
          Rule.new(key, value)
        end
      else
        InvalidLine.new(line)
      end
    end

    # @param rules [Array<UserAgentRule, AllowRule, DisallowRule, Rule, InvalidLine>]
    # @return [(Array<UserAgentRule, AllowRule, DisallowRule>, Array<AllowRule, DisallowRule, Rule, InvalidLine>)]
    def partition_rules(rules)
      standalone_rules = []
      grouped_rules = []
      rules.each do |rule|
        case rule
        when UserAgentRule
          grouped_rules << rule
        when AllowRule, DisallowRule
          if grouped_rules.empty?
            standalone_rules << rule
          else
            grouped_rules << rule
          end
        else
          standalone_rules << rule
        end
      end

      [grouped_rules, standalone_rules]
    end

    # @param rules [Array<UserAgentRule, AllowRule, DisallowRule>]
    # @return [Array<Group>]
    def group_rules(rules)
      rules
        .slice_when { |a, b| !a.is_a?(UserAgentRule) && b.is_a?(UserAgentRule) }
        .map { |group| Group.new(group) }
    end
  end
end
