# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gort::RobotsTxt do
  describe "access query" do
    it "implicitly allows /robots.txt" do
      robots = described_class.new([])
      expect(robots.allow?("random-agent", "/robots.txt")).to be true
      expect(robots.disallow?("random-agent", "/robots.txt")).to be false
    end

    it "allows allowed paths" do
      robots = described_class.new([
        Gort::Group.new([
          Gort::UserAgentRule.new("*"),
          Gort::AllowRule.new("/foo"),
        ]),
      ])
      expect(robots.allow?("random-agent", "/foo")).to be true
      expect(robots.disallow?("random-agent", "/foo")).to be false
    end

    it "allows access to unknown agents" do
      robots = described_class.new([
        Gort::Group.new([
          Gort::UserAgentRule.new("known-agent"),
          Gort::DisallowRule.new("/foo"),
        ]),
      ])
      expect(robots.allow?("random-agent", "/foo")).to be true
      expect(robots.disallow?("random-agent", "/foo")).to be false
    end

    it "uses the most specific match" do
      robots = described_class.new([
        Gort::Group.new([
          Gort::UserAgentRule.new("*"),
          Gort::AllowRule.new("/foo"),
          Gort::DisallowRule.new("/foo/path"),
        ]),
      ])
      expect(robots.allow?("agent", "/foo/path")).to be false
      expect(robots.disallow?("agent", "/foo/path")).to be true
    end

    it "uses the most specific match across all matching groups" do
      robots = described_class.new([
        Gort::Group.new([
          Gort::UserAgentRule.new("random-agent"),
          Gort::AllowRule.new("/foo"),
        ]),
        Gort::Group.new([
          Gort::UserAgentRule.new("specific-agent"),
          Gort::AllowRule.new("/foo/path"),
        ]),
        Gort::Group.new([
          Gort::UserAgentRule.new("*"),
          Gort::DisallowRule.new("/foo/path"),
        ]),
      ])
      expect(robots.allow?("random-agent", "/foo/path")).to be false
      expect(robots.disallow?("random-agent", "/foo/path")).to be true
    end

    it "uses the most specific match across all matching valid groups" do
      robots = described_class.new([
        Gort::Group.new([
          Gort::UserAgentRule.new("random-agent"),
          Gort::AllowRule.new("/foo"),
        ]),
        Gort::Group.new([
          Gort::UserAgentRule.new("random-agent/1"),
          Gort::AllowRule.new("/foo/path"),
        ]),
        Gort::Group.new([
          Gort::UserAgentRule.new("*"),
          Gort::DisallowRule.new("/foo/path"),
        ]),
      ])
      expect(robots.allow?("random-agent/1.42", "/foo/path")).to be false
      expect(robots.disallow?("random-agent/1.42", "/foo/path")).to be true
    end

    it "picks allow rules over equivalent disallow rule" do
      robots = described_class.new([
        Gort::Group.new([
          Gort::UserAgentRule.new("*"),
          Gort::AllowRule.new("/foo/bar"),
          Gort::DisallowRule.new("/foo/*"),
        ]),
      ])
      expect(robots.allow?("agent", "/foo/bar")).to be true
      expect(robots.disallow?("agent", "/foo/bar")).to be false
    end

    it "allows access with empty disallow rules" do
      robots = described_class.new([
        Gort::Group.new([
          Gort::UserAgentRule.new("*"),
          Gort::DisallowRule.new(""),
        ]),
      ])
      expect(robots.allow?("agent", "/foo")).to be true
      expect(robots.disallow?("agent", "/foo")).to be false
    end
  end
end
