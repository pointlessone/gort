# frozen_string_literal: true

module Gort
  # Represents an invalid line in a robots.txt file.
  #
  # @note Technically, the RFC doesn't have invalid lines in its grammar
  #   but there are just too many broken robots.txt files on the internet.
  #
  # An invalid line is a line that can not be parsed as a rule and is not a comment.
  class InvalidLine
    # @param text [String] content of the line
    def initialize(text)
      @value = text
    end

    # Content of the line.
    # @return [String]
    attr_reader :value

    # @!group Formatting Methods

    # A human readable representation of the invalid line.
    #
    # @return [String]
    # @tool
    #   :nocov:
    def inspect
      %(#<#{self.class.name}:#{object_id} "#{value}">)
    end
    # :nocov:

    # Produces a pretty human readable representation of the invalid line.
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
