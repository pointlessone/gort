# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gort::Parser do
  # This might be a brittle test. This is verys sensitive to how rchardet detect encodings.
  it "raises on invalid input encoding" do
    string = <<~ROBOTS_TXT.encode(Encoding::Windows_1252).force_encoding(Encoding::BINARY)
      ãäå˜ ï»¿
      User-agent: *
      Disallow:
    ROBOTS_TXT
    expect { described_class.new(string) }.to raise_error(described_class::InvalidEncodingError)
  end

  # This might be a brittle test. This is verys sensitive to how rchardet detect encodings.
  it "raises on binary input" do
    string = "\x0E\x06\e\f\x16\x04\x1F\x8d".dup.force_encoding(Encoding::BINARY)
    expect { described_class.new(string) }.to raise_error(described_class::BinaryInputError)
  end

  # This might be a brittle test. This is verys sensitive to how rchardet detect encodings.
  it "raises on misidentified encoding" do
    string = "\xea\xee\xf2\xe8\xea\xe8\x98".dup.force_encoding(Encoding::BINARY)
    expect { described_class.new(string) }.to raise_error(described_class::InvalidEncodingError)
  end

  it "removes BOM from the input text" do
    robots_txt = described_class.new("\xEF\xBB\xBFAllow: *").parse

    expect(robots_txt.rules.size).to eq(1)
    expect(robots_txt.rules.first).to be_a(Gort::AllowRule)
  end

  it "fixes encoding" do
    string = <<~ROBOTS_TXT.dup.encode(Encoding::IBM866)
      User-agent: *
      Allow: /котики
    ROBOTS_TXT
    robots_txt = described_class.new(string).parse

    value = robots_txt.rules[0].rules[1].value
    expect(value).to eq("/котики")
    expect(value.encoding).to eq(Encoding::UTF_8)
  end

  it "detects and fixes non-Unicode encoding" do
    string = <<~ROBOTS_TXT.encode(Encoding::IBM866).force_encoding(Encoding::ASCII_8BIT)
      User-agent: *
      Allow: /котики
    ROBOTS_TXT
    robots_txt = described_class.new(string).parse

    value = robots_txt.rules[0].rules[1].value
    expect(value).to eq("/котики")
    expect(value.encoding).to eq(Encoding::UTF_8)
  end

  context "with simple rules" do
    it "parses a simple allow rule" do
      rule_set = described_class.new(<<~ROBOTS_TXT).parse
        Allow: /allow
      ROBOTS_TXT

      expect(rule_set.rules.size).to eq(1)
      rule = rule_set.rules.first
      expect(rule).to be_a(Gort::AllowRule)
      expect(rule.value).to eq("/allow")
    end

    it "parses a simple disallow rule" do
      rule_set = described_class.new(<<~ROBOTS_TXT).parse
        Disallow: /disallow
      ROBOTS_TXT

      expect(rule_set.rules.size).to eq(1)
      rule = rule_set.rules.first
      expect(rule).to be_a(Gort::DisallowRule)
      expect(rule.value).to eq("/disallow")
    end

    it "parses a simple user-agent rule" do
      rule_set = described_class.new(<<~ROBOTS_TXT).parse
        User-agent: *
      ROBOTS_TXT

      expect(rule_set.rules.size).to eq(1)
      group = rule_set.rules.first
      expect(group).to be_a(Gort::Group)

      expect(group.rules.size).to eq(1)
      rule = group.rules.first
      expect(rule).to be_a(Gort::UserAgentRule)
      expect(rule.value).to eq("*")
    end

    it "prarses unknown rules" do
      rule_set = described_class.new(<<~ROBOTS_TXT).parse
        Unknown: mysterious
      ROBOTS_TXT

      expect(rule_set.rules.size).to eq(1)
      rule = rule_set.rules.first
      expect(rule).to be_a(Gort::Rule)
      expect(rule.name).to eq(:unknown)
      expect(rule.value).to eq("mysterious")
    end

    it "preserves invalid lines" do
      rule_set = described_class.new(<<~ROBOTS_TXT).parse
        Some random text
      ROBOTS_TXT

      expect(rule_set.rules.size).to eq(1)
      rule = rule_set.rules.first
      expect(rule).to be_a(Gort::InvalidLine)
      expect(rule.value).to eq("Some random text")
    end

    it "ignores comments" do
      rule_set = described_class.new(<<~ROBOTS_TXT).parse
        # Some comment
        Allow: /allow # Another comment
      ROBOTS_TXT

      expect(rule_set.rules.size).to eq(1)
      rule = rule_set.rules.first
      expect(rule).to be_a(Gort::AllowRule)
      expect(rule.value).to eq("/allow")
    end

    it "ignores blank lines" do
      rule_set = described_class.new(<<~ROBOTS_TXT).parse


        Allow: /allow


      ROBOTS_TXT

      expect(rule_set.rules.size).to eq(1)
      rule = rule_set.rules.first
      expect(rule).to be_a(Gort::AllowRule)
      expect(rule.value).to eq("/allow")
    end
  end

  context "with grouped rules" do
    it "groups adjacent user-agent rules" do
      rule_set = described_class.new(<<~ROBOTS_TXT).parse
        User-agent: crawler1
        User-agent: crawler2
        Disallow: /
      ROBOTS_TXT

      expect(rule_set.rules.size).to eq(1)
      group = rule_set.rules.first
      expect(group).to be_a(Gort::Group)

      expect(group.rules.size).to eq(3)
      expect(group.rules[0]).to be_a(Gort::UserAgentRule)
      expect(group.rules[0].value).to eq("crawler1")
      expect(group.rules[1]).to be_a(Gort::UserAgentRule)
      expect(group.rules[1].value).to eq("crawler2")

      expect(group.rules[2]).to be_a(Gort::DisallowRule)
      expect(group.rules[2].value).to eq("/")
    end

    it "properly groups rules" do
      rule_set = described_class.new(<<~ROBOTS_TXT).parse
        User-agent: crawler1
        Disallow: /
        User-agent: crawler2
        Allow: /all
      ROBOTS_TXT

      expect(rule_set.rules.size).to eq(2)

      group = rule_set.rules[0]
      expect(group).to be_a(Gort::Group)
      expect(group.rules.size).to eq(2)
      expect(group.rules[0]).to be_a(Gort::UserAgentRule)
      expect(group.rules[0].value).to eq("crawler1")
      expect(group.rules[1]).to be_a(Gort::DisallowRule)
      expect(group.rules[1].value).to eq("/")

      group = rule_set.rules[1]
      expect(group).to be_a(Gort::Group)
      expect(group.rules.size).to eq(2)
      expect(group.rules[0]).to be_a(Gort::UserAgentRule)
      expect(group.rules[0].value).to eq("crawler2")
      expect(group.rules[1]).to be_a(Gort::AllowRule)
      expect(group.rules[1].value).to eq("/all")
    end

    it "only groups access rules" do
      rule_set = described_class.new(<<~ROBOTS_TXT).parse
        User-agent: crawler1
        Unknown: mysterious
        Disallow: /
      ROBOTS_TXT

      expect(rule_set.rules.size).to eq(2)

      group = rule_set.rules[0]
      expect(group).to be_a(Gort::Group)
      expect(group.rules.size).to eq(2)
      expect(group.rules[0]).to be_a(Gort::UserAgentRule)
      expect(group.rules[0].value).to eq("crawler1")
      expect(group.rules[1]).to be_a(Gort::DisallowRule)
      expect(group.rules[1].value).to eq("/")

      rule = rule_set.rules[1]
      expect(rule).to be_a(Gort::Rule)
      expect(rule.name).to eq(:unknown)
      expect(rule.value).to eq("mysterious")
    end
  end
end
