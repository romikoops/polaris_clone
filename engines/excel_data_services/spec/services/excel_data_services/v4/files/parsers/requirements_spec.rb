# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Parsers::Requirements do
  include_context "V4 setup"

  let(:service) { described_class.new(section: section_string, state: state_arguments) }

  describe "#requirements" do
    let(:section_string) { "Pricings" }

    it "returns all Requirements defined in the schema", :aggregate_failures do
      expect(service.requirements.length).to eq(2)
      expect(service.requirements.map(&:class)).to eq([ExcelDataServices::V4::Files::Requirement] * 2)
    end

    context "when the requirements have specified sheets that don't match the available ones" do
      sheet_schema = {
        required: [{
          rows: "1:1",
          columns: "A:?",
          content: %w[NAME LOCODE TERMINAL],
          sheet_names: %w[Pricing]
        }]
      }

      before do
        allow(service).to receive(:schema_data).and_return(sheet_schema)
      end

      it "returns an empty array" do
        expect(service.requirements).to eq([])
      end
    end
  end
end
