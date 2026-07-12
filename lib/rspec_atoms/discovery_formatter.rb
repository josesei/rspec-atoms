# frozen_string_literal: true

require "rspec/core"

require_relative "example_id"

module RSpecAtoms
  class DiscoveryFormatter
    RSpec::Core::Formatters.register self, :example_started, :close

    def initialize(output)
      @output = output
    end

    def example_started(notification)
      @output.puts(
        ExampleId.normalize(notification.example.id)
      )
    end

    def close(_notification)
      @output.flush
    end
  end
end
