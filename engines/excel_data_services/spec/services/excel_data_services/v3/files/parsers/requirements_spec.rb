# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Files::Parsers::Requirements do
  include_context "V3 setup"

  let(:service) { described_class.new(section: section_string, state: state_arguments) }

  describe "#requirements" do
    let(:section_string) { "Pricings" }

    it "returns all Requirements defined in the schema", :aggregate_failures do
      expect(service.requirements.length).to eq(2)
      expect(service.requirements.map(&:class)).to eq([ExcelDataServices::V3::Files::Requirement] * 2)
    end

    context "when there are no requirements" do
      let(:section_string) { "ChargeCategory" }

      it "returns an empty array" do
        expect(service.requirements).to eq([])
      end
    end
  end
end
