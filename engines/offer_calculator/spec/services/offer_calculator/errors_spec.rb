# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Errors do
  let(:code) { OfferCalculator::Errors::CODE_LOOKUP.keys.first }
  let(:error) { OfferCalculator::Errors::CODE_LOOKUP.values.first }

  describe ".from_code" do
    it "returns the correct Error for the code" do
      expect(described_class.from_code(code: code)).to eq(error)
    end
  end

  describe ".code" do
    it "returns the correct Error for the code" do
      expect(error.new.code).to eq(code)
    end
  end
end
