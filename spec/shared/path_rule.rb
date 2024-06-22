# frozen_string_literal: true

RSpec.shared_examples "path rule" do
  let(:rule_requires_name) { false }

  def build_rule(value)
    if rule_requires_name
      described_class.new(:test, value)
    else
      described_class.new(value)
    end
  end

  describe "#valid?" do
    it "is valid when empty" do
      rule = build_rule("")
      expect(rule).to be_valid
    end

    it "is valid with a regular path" do
      rule = build_rule("/path/to/resource")
      expect(rule).to be_valid
    end

    it "is valid with a path containing a wildcard" do
      rule = build_rule("/path/*/resource")
      expect(rule).to be_valid
    end

    it "is valid with a path containing an end of match" do
      rule = build_rule("/this/path/exactly$")
      expect(rule).to be_valid
    end

    it "is invalid with $ anywhere but the end" do
      rule = build_rule("/this/path$exactly")
      expect(rule).not_to be_valid
    end

    (0..31).each do |char|
      it "is invalid with a path containing control character 0x#{format '%02x', char}" do
        rule = build_rule("/path/to/#{char.chr}")
        expect(rule).not_to be_valid
      end
    end

    it "is invalid with a path containing a space" do
      rule = build_rule("/path with spaces")
      expect(rule).not_to be_valid
    end

    it "is invalid with a path containing an octothorp" do
      rule = build_rule("/path#with#octothorps")
      expect(rule).not_to be_valid
    end

    it "is valid with a wildcard at the beginning" do
      rule = build_rule("*.gif")
      expect(rule).to be_valid
    end

    it "is invalid when starting with anything but / or *" do
      rule = build_rule("path")
      expect(rule).not_to be_valid
    end
  end

  describe "#match" do
    it "doesn't match when invalid" do
      rule = build_rule("invalid")
      expect(rule.match("invalid")).to be_nil
    end

    it "matches on prefix" do
      rule = build_rule("/path")
      match = rule.match("/path/to/resource")

      expect(match).not_to be_nil
      expect(match[0]).to eq 5 # length of match
      expect(match[1]).to eq rule
    end

    it "matches regardless of perceived path components boundaries" do
      rule = build_rule("/path/to")
      match = rule.match("/path/towards")

      expect(match).not_to be_nil
      expect(match[0]).to eq 8
      expect(match[1]).to eq rule
    end

    it "matches on wildcards" do
      rule = build_rule("/path/*")
      match = rule.match("/path/to/resource")

      expect(match).not_to be_nil
      expect(match[0]).to eq 17
      expect(match[1]).to eq rule
    end

    it "matches on encoded paths" do
      rule = build_rule("/path/*")
      match = rule.match("/path/to/ресурс")

      expect(match).not_to be_nil
      expect(match[0]).to eq 45 # match length in bytes of the encoded path
      expect(match[1]).to eq rule
    end

    it "matches on paths and queries" do
      rule = build_rule("/path?to=*")
      match = rule.match("/path?to=resource")

      expect(match).not_to be_nil
      expect(match[0]).to eq 17
      expect(match[1]).to eq rule
    end

    it "matches on end of pattern" do
      rule = build_rule("/path$")
      match = rule.match("/path")

      expect(match).not_to be_nil
      expect(match[0]).to eq 5
      expect(match[1]).to eq rule
    end

    it "doesn't match past the end of pattern" do
      rule = build_rule("/path$")
      match = rule.match("/path/to_resource")

      expect(match).to be_nil
    end

    it "doesn't match literal $" do
      rule = build_rule("/path$")
      match = rule.match("/path$")

      expect(match).to be_nil
    end

    it "matches encoded literal $" do
      rule = build_rule("/path%24")
      match = rule.match("/path$")

      expect(match).not_to be_nil
      expect(match[0]).to eq 6 # normalization decodes the literal $
      expect(match[1]).to eq rule
    end

    it "unencodes encoded ASCII" do
      rule = build_rule("/%70%61%74%68")
      match = rule.match("/path")

      expect(match).not_to be_nil
      expect(match[0]).to eq 5
      expect(match[1]).to eq rule
    end

    it "matches with case" do
      rule = build_rule("/path")
      match = rule.match("/Path")

      expect(match).to be_nil
    end

    it "doesn't match anything when empty" do
      rule = build_rule("")
      match = rule.match("/path")

      expect(match).to be_nil
    end
  end
end
