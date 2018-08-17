# frozen_string_literal: true

require "spec_helper"

RSpec.describe ChargeCalculator::Models::CargoUnit do
  subject { described_class.new(data: { payload: "100.0" }) }

  context "method_missing" do
    it "accesses a given data attribute" do
      expect(subject.payload).to eq("100.0")
    end

    it "raises a NoMethodError if attribute cannot be found" do
      expect { subject.foo }.to raise_error(NoMethodError)
    end
  end
end
