# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gort do
  it "has a version number" do
    expect(described_class::VERSION).not_to be_nil
  end

  describe ".parse" do
    it "returns and instance of RobotsTxt" do
      expect(described_class.parse("")).to be_a(described_class::RobotsTxt)
    end

    it "implicitly allows access to /robots.txt" do
      robots_txt = described_class.parse(<<~ROBOTS_TXT)
        User-agent: *
        Disallow: /
      ROBOTS_TXT
      expect(robots_txt.allow?("random-agent", "/robots.txt")).to be true
    end

    it "allows access to allowed paths" do
      robots_txt = described_class.parse(<<~ROBOTS_TXT)
        User-agent: *
        Allow: /foo
      ROBOTS_TXT
      expect(robots_txt.allow?("random-agent", "/foo")).to be true
    end

    it "disallows access to disallowed paths" do
      robots_txt = described_class.parse(<<~ROBOTS_TXT)
        User-agent: *
        Disallow: /foo
      ROBOTS_TXT
      expect(robots_txt.disallow?("random-agent", "/foo")).to be true
    end

    it "allows access to unlisted paths" do
      robots_txt = described_class.parse(<<~ROBOTS_TXT)
        User-agent: *
        Disallow: /foo
      ROBOTS_TXT
      expect(robots_txt.allow?("random-agent", "/bar")).to be true
    end

    it "uses the most specific match" do
      robots_txt = described_class.parse(<<~ROBOTS_TXT)
        User-agent: *
        Allow: /foo
        Disallow: /foo/path
      ROBOTS_TXT
      expect(robots_txt.allow?("agent", "/foo/path")).to be false
    end

    it "uses the most specific match across all matching groups" do
      robots_txt = described_class.parse(<<~ROBOTS_TXT)
        User-agent: *
        Disallow: /foo
        User-agent: specific-agent
        Allow: /foo/path
      ROBOTS_TXT
      expect(robots_txt.allow?("specific-agent", "/foo/bar")).to be false
      expect(robots_txt.allow?("specific-agent", "/foo/path")).to be true
    end

    it "allows access to unlisted agents" do
      robots_txt = described_class.parse(<<~ROBOTS_TXT)
        User-agent: known-agent
        Disallow: /foo
      ROBOTS_TXT
      expect(robots_txt.allow?("random-agent", "/foo")).to be true
    end

    it "disallows access to disallowed agents" do
      robots_txt = described_class.parse(<<~ROBOTS_TXT)
        User-agent: known-agent
        Disallow: /foo
      ROBOTS_TXT
      expect(robots_txt.disallow?("known-agent", "/foo")).to be true
    end

    it "understands wildcards" do
      robots_txt = described_class.parse(<<~ROBOTS_TXT)
        User-agent: *
        Disallow: /foo*
        Disallow: *.backup
      ROBOTS_TXT
      expect(robots_txt.disallow?("random-agent", "/foo")).to be true
      expect(robots_txt.disallow?("random-agent", "/foo/bar")).to be true
      expect(robots_txt.disallow?("random-agent", "/foo/bar/baz")).to be true
      expect(robots_txt.disallow?("random-agent", "/foobar")).to be true
      expect(robots_txt.disallow?("random-agent", "/bar/baz.backup")).to be true
      expect(robots_txt.disallow?("random-agent", "/bar.backup/baz")).to be true
      expect(robots_txt.allow?("random-agent", "/bar")).to be true
    end

    it "understands multiple user-agents" do
      robots_txt = described_class.parse(<<~ROBOTS_TXT)
        User-agent: agent-a
        User-agent: agent-b
        Disallow: /bar
      ROBOTS_TXT
      expect(robots_txt.disallow?("agent-a", "/bar")).to be true
      expect(robots_txt.disallow?("agent-b", "/bar")).to be true
    end

    it "matches user-agent by substring inclusion" do
      robots_txt = described_class.parse(<<~ROBOTS_TXT)
        User-agent: agent
        Disallow: /bar
      ROBOTS_TXT
      expect(robots_txt.disallow?("agent/1", "/bar")).to be true
    end

    it "ignores malformed user-agents" do
      robots_txt = described_class.parse(<<~ROBOTS_TXT)
        # No slashes or numbers alloed in user-agent®
        User-agent: agent/1
        Disallow: /bar
      ROBOTS_TXT
      expect(robots_txt.disallow?("agent/1.3", "/bar")).to be false
    end

    it "understands end of match" do
      robots_txt = described_class.parse(<<~ROBOTS_TXT)
        User-agent: *
        Disallow: /foo$
      ROBOTS_TXT
      expect(robots_txt.disallow?("random-agent", "/foo")).to be true
      expect(robots_txt.disallow?("random-agent", "/foo/bar")).to be false
    end

    it "picks the most specific match" do
      robots_txt = described_class.parse(<<~ROBOTS_TXT)
        User-agent: *
        Disallow: /foo*
        Allow: /foo/bar
      ROBOTS_TXT
      expect(robots_txt.disallow?("random-agent", "/foo/bar/baz")).to be true
    end

    it "picks allow for the same match" do
      robots_txt = described_class.parse(<<~ROBOTS_TXT)
        User-agent: *
        Disallow: /foo*
        Allow: /foo/bar
      ROBOTS_TXT
      expect(robots_txt.allow?("random-agent", "/foo/bar")).to be true
    end

    it "normalizes URLs" do
      robots_txt = described_class.parse(<<~ROBOTS_TXT)
        User-agent: *
        Disallow: /їжачки
      ROBOTS_TXT
      expect(robots_txt.disallow?("random-agent", "/%D1%97%D0%B6%D0%B0%D1%87%D0%BA%D0%B8/bar")).to be true
    end

    it "marches encoded special characters" do
      robots_txt = described_class.parse(<<~ROBOTS_TXT)
        User-agent: *
        Disallow: /foo-%2a%24
      ROBOTS_TXT
      expect(robots_txt.disallow?("random-agent", "/foo-*$/bar")).to be true
    end

    it "matches on query strings" do
      robots_txt = described_class.parse(<<~ROBOTS_TXT)
        User-agent: *
        Disallow: /foo?bar=baz
      ROBOTS_TXT
      expect(robots_txt.disallow?("random-agent", "/foo?bar=baz&qux=quux")).to be true
    end
  end
end
