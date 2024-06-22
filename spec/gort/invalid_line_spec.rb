# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gort::InvalidLine do
  it "just hold the line" do
    expect(described_class.new("foo").value).to eq("foo")
  end
end
