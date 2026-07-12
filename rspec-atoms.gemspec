# frozen_string_literal: true

require_relative "lib/rspec_atoms/version"

Gem::Specification.new do |spec|
  spec.name = "rspec-atoms"
  spec.version = RSpecAtoms::VERSION
  spec.authors = ["Jose Carbone"]
  spec.email = ["joseignaciocarbone@gmail.com"]

  spec.summary = "Split RSpec suites by runnable example"
  spec.description = <<~DESCRIPTION
    Discovers runnable RSpec examples as RSpec IDs and emits matching JUnit
    identities for CircleCI Smarter Testing.
  DESCRIPTION
  spec.homepage = "https://github.com/josesei/rspec-atoms"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4"

  spec.files = Dir[
    "lib/**/*",
    "exe/*",
    "README.md",
    "LICENSE.txt"
  ]

  spec.bindir = "exe"
  spec.executables = ["rspec-atoms"]
  spec.require_paths = ["lib"]

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["source_code_uri"] = spec.homepage

  spec.add_dependency "rspec-core", ">= 3.13", "< 4"
  spec.add_dependency "rspec_junit_formatter", ">= 0.6", "< 1"

  spec.add_development_dependency "rake", ">= 13"
  spec.add_development_dependency "rexml"
  spec.add_development_dependency "rspec", ">= 3.13", "< 4"
end
