# frozen_string_literal: true

require_relative "discover"
require_relative "run"
require_relative "version"

module RSpecAtoms
  class CLI
    EXIT_USAGE = 64

    def self.start(arguments, output: $stdout, error: $stderr)
      arguments = arguments.dup
      command = arguments.shift

      case command
      when "discover"
        Discover.call(arguments, output: output, error: error)
      when "run"
        junit_output = extract_option!(
          arguments,
          "--junit",
          default: Run::DEFAULT_JUNIT_OUTPUT
        )
        arguments.shift if arguments.first == "--"

        Run.call(
          arguments,
          junit_output: junit_output,
          output: output,
          error: error
        )
      when "version", "--version", "-v"
        output.puts(VERSION)
        0
      else
        error.puts(usage)
        EXIT_USAGE
      end
    rescue ArgumentError => exception
      error.puts(exception.message)
      error.puts(usage)
      EXIT_USAGE
    end

    def self.extract_option!(arguments, option, default:)
      index = arguments.index(option)
      return default unless index

      value = arguments[index + 1]
      if value.nil? || value.empty? || value == "--"
        raise ArgumentError, "Missing #{option} PATH"
      end

      arguments.slice!(index, 2)
      value
    end

    def self.usage
      <<~USAGE
        Usage:
          rspec-atoms discover [RSpec arguments]
          rspec-atoms run [--junit PATH] -- [RSpec arguments]
          rspec-atoms version
      USAGE
    end

    private_class_method :extract_option!, :usage
  end
end
