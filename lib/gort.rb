# frozen_string_literal: true

require_relative "gort/version"

# Gort is a robots.txt parser and evaluator.
module Gort
  # Gort's top error class. All other errors inherit from this.
  class Error < StandardError; end

  # Parse the given robots.txt input and return a RobotsTxt instance.
  #
  # @param input [String] the robots.txt input to parse
  # @return [RobotsTxt] the parsed robots.txt
  def self.parse(input)
    Parser.new(input).parse
  end
end

require_relative "gort/parser"
