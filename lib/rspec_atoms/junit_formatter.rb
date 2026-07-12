# frozen_string_literal: true

require "rspec_junit_formatter"

require_relative "example_id"

module RSpecAtoms
  class JunitFormatter < ::RSpecJUnitFormatter
    RSpec::Core::Formatters.register(
      self,
      :start,
      :stop,
      :dump_summary
    )

    private

    def example_group_file_path_for(notification)
      ExampleId.normalize(notification.example.id)
    end

    def classname_for(notification)
      ExampleId
        .file_path(notification.example.id)
        .sub(%r{\.[^/]*\z}, "")
        .tr("/", ".")
        .gsub(/\A\.+|\.+\z/, "")
    end
  end
end
