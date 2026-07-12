# frozen_string_literal: true

RSpec.describe RSpecAtoms::ExampleId do
  let(:example_id) { "./spec/workers/example_spec.rb[1:2:3]" }

  describe "#normalize" do
    subject(:normalized_id) { described_class.normalize(example_id) }

    it "removes a leading dot slash" do
      expect(normalized_id).to eq(
        "spec/workers/example_spec.rb[1:2:3]"
      )
    end

    context "when the ID is already normalized" do
      let(:example_id) { "spec/workers/example_spec.rb[1:2:3]" }

      it "leaves it unchanged" do
        expect(normalized_id).to eq(example_id)
      end
    end
  end

  describe "#file_path" do
    subject(:file_path) { described_class.file_path(example_id) }

    it "removes the RSpec selector" do
      expect(file_path).to eq("spec/workers/example_spec.rb")
    end
  end
end
