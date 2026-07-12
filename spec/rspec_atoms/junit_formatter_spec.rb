# frozen_string_literal: true

require "rspec_atoms/junit_formatter"

RSpec.describe RSpecAtoms::JunitFormatter do
  subject(:formatter) { described_class.allocate }

  let(:example_id) { "./spec/features/example_spec.rb[1:2]" }
  let(:example) { double("example", id: example_id) }
  let(:notification) { double("notification", example: example) }

  describe "#example_group_file_path_for" do
    it "returns the normalized RSpec example ID" do
      expect(
        formatter.send(:example_group_file_path_for, notification)
      ).to eq("spec/features/example_spec.rb[1:2]")
    end
  end

  describe "#classname_for" do
    let(:example_id) do
      "./spec/features/planned_loads/filter_spec.rb[1:3:2]"
    end

    it "builds a classname from the spec file path" do
      expect(formatter.send(:classname_for, notification)).to eq(
        "spec.features.planned_loads.filter_spec"
      )
    end
  end
end
