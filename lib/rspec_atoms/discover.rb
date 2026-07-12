# frozen_string_literal: true

require "rspec/core"
require "stringio"
require "tempfile"

require_relative "discovery_formatter"

module RSpecAtoms
  module Discover
    module_function

    def call(arguments, output: $stdout, error: $stderr)
      Tempfile.create(["rspec-atoms", ".txt"]) do |atoms_file|
        runner_output = StringIO.new
        RSpec.configuration.fail_if_no_examples = true

        status = RSpec::Core::Runner.run(
          rspec_arguments(arguments, atoms_file.path),
          error,
          runner_output
        )

        if status.zero?
          atoms_file.rewind
          IO.copy_stream(atoms_file, output)
        else
          write_runner_output(runner_output, error)
        end

        status
      end
    end

    def rspec_arguments(arguments, atoms_path)
      [
        "--dry-run",
        "--no-color",
        "--format",
        "RSpecAtoms::DiscoveryFormatter",
        "--out",
        atoms_path,
        *arguments
      ]
    end

    def write_runner_output(runner_output, error)
      content = runner_output.string
      return if content.empty?

      error.write(content)
      error.write("\n") unless content.end_with?("\n")
    end
  end
end
