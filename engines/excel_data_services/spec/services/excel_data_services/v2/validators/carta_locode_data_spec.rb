# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Validators::CartaLocodeData do
  include_context "for excel_data_services setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:nexus) { FactoryBot.create(:legacy_nexus, name: "test") }

  describe ".state" do
    let(:row) do
      {
        "locode" => "DEHAM",
        "row" => 2
      }
    end

    context "when found" do
      before do
        allow(Carta::Client).to receive(:suggest).with(query: "DEHAM").and_return(
          FactoryBot.build(:carta_result, latitude: 10.15, longitude: 11.5, address: "DEHAM")
        )
        allow(Carta::Client).to receive(:reverse_geocode).with(latitude: 10.15, longitude: 11.5).and_return(
          FactoryBot.build(:carta_result, latitude: 10.15, longitude: 11.5, address: "Hamburg, Germany", country: "Germany", locality: "Hamburg")
        )
      end

      it "returns the frame with the location data based off the locode" do
        expect(extracted_table.to_a.first).to eq(
          row.merge("latitude" => 10.15, "longitude" => 11.5, "address" => "Hamburg, Germany", "country" => "Germany", "locode_found" => true)
        )
      end
    end

    context "when not found" do
      let(:error_messages) do
        ["The locode 'DEHAM' cannot be found in our routing. Please consult the official UN/LOCODE list (https://locode.info)"]
      end

      before do
        allow(Carta::Client).to receive(:suggest).with(query: "DEHAM").and_raise(Carta::Client::LocationNotFound)
      end

      it "appends an error to the state", :aggregate_failures do
        expect(result.errors).to be_present
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end
  end
end
