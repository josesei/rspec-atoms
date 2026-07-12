# frozen_string_literal: true

RSpec.shared_context "shared setup" do
  let(:value) { 42 }
end

RSpec.shared_examples "shared behavior" do
  it "works from a shared example" do
    expect(value).to eq(42)
  end
end

RSpec.describe "Example suite" do
  include_context "shared setup"

  it "runs normally" do
    expect(value).to eq(42)
  end

  context "when nested" do
    include_examples "shared behavior"
  end
end
