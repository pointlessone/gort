# frozen_string_literal: true

require "spec_helper"
require "shared/path_rule"

RSpec.describe Gort::DisallowRule do
  it_behaves_like "path rule"
end
