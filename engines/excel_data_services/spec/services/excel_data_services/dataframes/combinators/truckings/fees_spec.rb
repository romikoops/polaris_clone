# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Combinators::Truckings::Fees do
  include_context "with standard trucking setup"
  include_context "with trucking_sheet"

  before do
    Organizations.current_id = organization.id
    tenant_vehicle
  end

  let(:country_code) { country.code }
  let(:country) { FactoryBot.create(:country_de) }
  let(:carrier_name) { "Gateway Cargo GmbH" }
  let(:truckings) { ::Trucking::Trucking.all }
  let(:trucking_hub_availabilities) { ::Trucking::HubAvailability.all }
  let(:trucking_type_availabilities) { ::Trucking::TypeAvailability.all }
  let(:expected_result) do
    [{"fee" => "Fuel Surcharge",
      "mot" => "truck_carriage",
      "fee_code" => "FSC",
      "truck_type" => "default",
      "direction" => "export",
      "currency" => "EUR",
      "rate_basis" => "PER_SHIPMENT",
      "ton" => Float::NAN,
      "cbm" => Float::NAN,
      "kg" => Float::NAN,
      "item" => Float::NAN,
      "shipment" => 120.0,
      "bill" => Float::NAN,
      "container" => Float::NAN,
      "minimum" => Float::NAN,
      "wm" => Float::NAN,
      "percentage" => Float::NAN,
      "carriage" => "pre"}]
  end

  describe ".frame" do
    let!(:result) do
      described_class.state(coordinator_state: parent_arguments)
    end

    it "returns successfully" do
      expect(result.frame.to_a.first.inspect).to eq(expected_result.first.inspect)
    end
  end
end
