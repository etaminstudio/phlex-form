# frozen_string_literal: true

require_relative "lib/phlex/form/version"

Gem::Specification.new do |spec|
  spec.name        = "phlex-form"
  spec.version     = Phlex::Form::VERSION
  spec.authors     = ["Hans Lemuet"]

  spec.summary     = "Rails FormBuilder rendering Phlex components"
  spec.description = "A Rails FormBuilder whose helpers render Phlex components, in ERB, Slim or Phlex views. " \
                     "Derived from view_component-form."
  spec.homepage    = "https://github.com/etaminstudio/phlex-form"
  spec.license     = "MIT"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "changelog_uri" => "https://github.com/etaminstudio/phlex-form/blob/main/CHANGELOG.md",
    "source_code_uri" => spec.homepage,
    "bug_tracker_uri" => "https://github.com/etaminstudio/phlex-form/issues",
    "rubygems_mfa_required" => "true"
  }

  spec.files         = Dir["CHANGELOG.md", "LICENSE.txt", "README.md", "lib/**/*"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = Gem::Requirement.new(">= 3.3.0")

  spec.add_dependency "actionview", [">= 8.1"]
  spec.add_dependency "activesupport", [">= 8.1"]
  spec.add_dependency "phlex-rails", ["~> 2.4"]
  spec.add_dependency "zeitwerk", ["~> 2.6"]
end
