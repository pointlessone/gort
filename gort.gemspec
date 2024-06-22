# frozen_string_literal: true

require_relative "lib/gort/version"

Gem::Specification.new do |spec|
  spec.name = "gort"
  spec.version = Gort::VERSION
  spec.authors = ["Alexander Mankuta"]
  spec.email = ["alex@pointless.one"]

  spec.summary = "robots.txt parser and evaluator."
  spec.description = "robots.txt parser and evaluator according to RFC 9309."
  # spec.homepage = "TODO: Put your gem's website or public repo URL here."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  if File.basename($PROGRAM_NAME) == "gem" && ARGV.include?("build")
    signing_key = File.expand_path("~/.gem/gem-private_key.pem")
    if File.exist?(signing_key)
      spec.cert_chain = ["certs/pointlessone.pem"]
      spec.signing_key = signing_key
    else
      warn "WARNING: Signing key is missing. The gem is not signed and its authenticity can not be verified."
    end
  end

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["rubygems_mfa_required"] = "true"

  # spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/pointlessone/gort"
  spec.metadata["changelog_uri"] = "https://github.com/pointlessone/gort/blob/main/CHANGELOG.md"

  spec.files = Dir.glob(["lib/**/*.rb", "LICENSE.txt"])
  spec.require_paths = ["lib"]

  spec.add_dependency "addressable", "~> 2.8"
  spec.add_dependency "rchardet", "~> 1.8"
end
