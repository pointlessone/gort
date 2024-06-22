# frozen_string_literal: true

RSpec.shared_examples "rule set" do
  it "merges two rule sets" do
    rule1 = Gort::Rule.new(:dummy, "rule 1")
    rule_set = described_class.new([rule1])
    rule2 = Gort::Rule.new(:dummy, "rule 2")
    other = described_class.new([rule2])

    merged = rule_set.merge(other)

    expect(merged.rules.size).to eq(2)
    expect(merged.rules).to eq [rule1, rule2]
  end
end
