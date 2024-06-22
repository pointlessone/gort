# frozen_string_literal: true

require "spec_helper"
require "shared/path_rule"

RSpec.describe Gort::PathRule do
  it_behaves_like "path rule" do
    let(:rule_requires_name) { true }
  end
end
