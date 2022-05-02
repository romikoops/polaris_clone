# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::Country do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:country) { FactoryBot.create(:legacy_country) }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "country" => country.name,
          "row" => 2
        }
      end

      it "returns the frame with the country_id" do
        expect(extracted_table["country_id"].to_a).to eq([country.id])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "country" => "AAA",
          "row" => 2
        }
      end

      it "does not find the record or add a country_id" do
        expect(extracted_table["country_id"].to_a).to eq([nil])
      end
    end
  end
end
