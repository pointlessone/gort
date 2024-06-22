# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gort::Rule do
  it "holds a name and a value" do
    rule = described_class.new("foo", "bar")
    expect(rule.name).to eq(:foo)
    expect(rule.value).to eq("bar")
  end
end
