# frozen_string_literal: true

require_relative "lib/nokogiri/html_ext/version"

Gem::Specification.new do |spec|
  spec.required_ruby_version = ">= 2.7"

  spec.name          = "nokogiri-html-ext"
  spec.version       = Nokogiri::HTMLExt::VERSION
  spec.authors       = ["Jason Garber"]
  spec.email         = ["jason@sixtwothree.org"]

  spec.summary       = "Extend Nokogiri with several useful HTML-centric features."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/jgarber623/nokogiri-html-ext"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"].reject { |f| File.directory?(f) }
  spec.files        += ["LICENSE", "CHANGELOG.md", "README.md"]
  spec.files        += ["nokogiri-html-ext.gemspec"]

  spec.require_paths = ["lib"]

  spec.metadata = {
    "bug_tracker_uri"       => "#{spec.homepage}/issues",
    "changelog_uri"         => "#{spec.homepage}/blob/v#{spec.version}/CHANGELOG.md",
    "rubygems_mfa_required" => "true"
  }

  spec.add_runtime_dependency "nokogiri", ">= 1.14"
end
