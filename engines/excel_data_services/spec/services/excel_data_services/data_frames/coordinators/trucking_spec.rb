# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Coordinators::Trucking do
  include_context "with standard trucking setup"
  include_context "with trucking_sheet"

  before do
    Locations::Name.search_index.delete
    Organizations.current_id = organization.id
  end

  let(:zone_type) { :alphanumeric }
  let(:query_method) { "location" }
  let(:truckings) { ::Trucking::Trucking.all }
  let(:trucking_hub_availabilities) { ::Trucking::HubAvailability.all }
  let(:trucking_type_availabilities) { ::Trucking::TypeAvailability.all }
  let(:coordinator) { described_class.state(state: parent_arguments) }

  describe ".perform" do
    context "with fees" do
      let(:expected_fees) do
        {
          "FSC" => {
            "fee" => "Fuel Surcharge",
            "currency" => "EUR",
            "rate_basis" => "PER_SHIPMENT",
            "shipment" => 120.0,
            "key" => "FSC"
          }
        }
      end

      it "returns successfully", :aggregate_failures do
        expect(coordinator.frame.count).to eq(11)
        expect(coordinator.frame["fees"].to_a.uniq).to match_array([expected_fees])
      end
    end

    context "without fees" do
      let(:expected_fees) do
        {}
      end
      let(:fee_trait) { :no_fees }

      it "returns successfully", :aggregate_failures do
        expect(coordinator.frame.count).to eq(11)
        expect(coordinator.frame["fees"].to_a.uniq).to match_array([expected_fees])
      end
    end
  end
end
