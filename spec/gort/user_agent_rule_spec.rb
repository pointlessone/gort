# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gort::UserAgentRule do
  describe "#valid?" do
    it "returns true for valid user agent" do
      rule = described_class.new("Mozilla")
      expect(rule.valid?).to be true
    end

    it "returns false for invalid user agent" do
      rule = described_class.new("Mozilla/5.0")
      expect(rule.valid?).to be false
    end
  end
end
