# frozen_string_literal: true

require "rspec_atoms/run"

RSpec.describe RSpecAtoms::Run do
  describe "#inject_formatters" do
    subject(:injected_arguments) do
      described_class.inject_formatters(arguments, junit_output)
    end

    let(:arguments) do
      ["--profile", "10", "--", "spec/example_spec.rb[1:1]"]
    end
    let(:junit_output) { "report.xml" }

    it "adds progress and JUnit formatters before the selector separator" do
      expect(injected_arguments).to eq(
        [
          "--profile",
          "10",
          "--format",
          "progress",
          "--format",
          "RSpecAtoms::JunitFormatter",
          "--out",
          "report.xml",
          "--",
          "spec/example_spec.rb[1:1]"
        ]
      )
    end
  end
end
