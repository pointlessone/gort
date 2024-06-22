# frozen_string_literal: true

require_relative "rule"
require "addressable/uri"

module Gort
  # A rule that matches a path and query string.
  #
  # @abstract
  class PathRule < Rule
    # Path patter has to start with a slash and not contain control characters or hash.
    # It also has to be a valid UTF-8 string but this is checked diring parsing.
    # It also can be empty.
    PATH_PATTERN = %r{\A(?:[/*][^\u0000-\u0020\u0023$]*\$?)?\z}u
    private_constant :PATH_PATTERN

    def valid?
      value.match?(PATH_PATTERN)
    end

    # Match the path and query string against the rule.
    # Invalid rules never match.
    # Empty rules never match, either. This is not explicitly stated in the RFC
    # but it is explicitly described in previous robots.txt documents.
    #
    # @param path_and_query [String]
    # @return [nil, (Integer, PathRule)]
    #   - +nil+ if the rule does not match the path and query string.
    #   - An array with the number of bytes matched and the rule itself if the rule matches.
    def match(path_and_query)
      return nil if !valid? || value.empty?

      path_and_query = normalize_path_and_query(path_and_query)
      match = path_and_query.match(regexp)
      return nil unless match

      [match.to_s.bytesize, self]
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

    private

    # @param path_and_query [String]
    # @return [String]
    def normalize_path_and_query(path_and_query)
      pq = Addressable::URI.parse(path_and_query).normalize
      pq.scheme = nil
      pq.authority = nil
      pq.fragment = nil
      pq.to_s
    end

    # @return [Regexp]
    def regexp
      @regexp ||=
        begin
          parts = value.scan(/[^*$]+|[*$]/)
          regexp_parts =
            parts.map { |part|
              case part
              when "*"
                ".*"
              when "$"
                "\\z"
              else
                Regexp.escape(Addressable::URI.normalized_encode(part))
              end
            }

          Regexp.new("\\A#{regexp_parts.join}")
        end
    end
  end
end
