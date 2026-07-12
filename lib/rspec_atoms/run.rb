# frozen_string_literal: true

require "fileutils"
require "rspec/core"

require_relative "junit_formatter"

module RSpecAtoms
  module Run
    DEFAULT_JUNIT_OUTPUT = "tmp/rspec.xml"

    module_function

    def call(
      arguments,
      junit_output: DEFAULT_JUNIT_OUTPUT,
      output: $stdout,
      error: $stderr
    )
      ensure_output_directory(junit_output)

      RSpec::Core::Runner.run(
        inject_formatters(arguments, junit_output),
        error,
        output
      )
    end

    def inject_formatters(arguments, junit_output)
      separator_index = arguments.index("--") || arguments.length
      options = arguments[0...separator_index]
      selectors = arguments[separator_index..] || []

      [
        *options,
        "--format",
        "progress",
        "--format",
        "RSpecAtoms::JunitFormatter",
        "--out",
        junit_output,
        *selectors
      ]
    end

    def ensure_output_directory(junit_output)
      directory = File.dirname(junit_output)
      return if directory == "."

      FileUtils.mkdir_p(directory)
    end
  end
end
