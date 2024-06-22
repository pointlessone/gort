# frozen_string_literal: true

require "spec_helper"
require "shared/rule_set"

RSpec.describe Gort::Group do
  it_behaves_like "rule set"

  describe "#apply?" do
    it "returns true for all user agents" do
      group = described_class.new([Gort::UserAgentRule.new("*")])
      expect(group.apply?("Mozilla")).to be true
    end

    it "returns true for a matching specific user agent" do
      group = described_class.new([Gort::UserAgentRule.new("Mozilla")])
      expect(group.apply?("Mozilla/5.0")).to be true
    end

    it "returns false for a specific user agent that doesn't match" do
      group = described_class.new([Gort::UserAgentRule.new("Chrome")])
      expect(group.apply?("Mozilla/5.0")).to be false
    end
  end
end
