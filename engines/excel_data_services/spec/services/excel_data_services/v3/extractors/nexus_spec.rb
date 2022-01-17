# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Extractors::Nexus do
  include_context "V3 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:nexus) { FactoryBot.create(:legacy_nexus, :segot, organization: organization) }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "name" => nexus.name,
          "locode" => nexus.locode,
          "country" => nexus.country.name,
          "row" => 2
        }
      end

      it "returns the frame with the nexus_id" do
        expect(extracted_table["nexus_id"].to_a).to eq([nexus.id])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "name" => "AAA",
          "locode" => "BBBB",
          "country" => "CCC",
          "row" => 2
        }
      end

      it "does not find the record or add a nexus_id" do
        expect(extracted_table["nexus_id"].to_a).to eq([nil])
      end
    end
  end
end
