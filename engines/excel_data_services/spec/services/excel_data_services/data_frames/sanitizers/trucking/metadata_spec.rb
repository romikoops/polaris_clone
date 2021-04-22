# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Sanitizers::Trucking::Metadata do
  let(:frame_data) do
    { "city" => "Hamburg ",
      "currency" => "eur",
      "load_meterage_ratio" => "1500",
      "load_meterage_stackable_limit" => "4.765",
      "load_meterage_non_stackable_limit" => "4.765",
      "load_meterage_stackable_type" => "Area",
      "load_meterage_non_stackable_type" => "ldM",
      "load_meterage_hard_limit" => nil,
      "cbm_ratio" => "250.0",
      "scale" => "KG",
      "rate_basis" => "per_shipment",
      "base" => 1,
      "truck_type" => "DEFault",
      "load_type" => "cargo_item ",
      "cargo_class" => "LCL ",
      "direction" => "Export ",
      "carrier" => "Gateway Cargo GmbH ",
      "service" => nil }
  end
  let(:expected_results) do
    { "city" => "Hamburg",
      "currency" => "EUR",
      "load_meterage_ratio" => 1500.0,
      "load_meterage_stackable_limit" => 4.765,
      "load_meterage_non_stackable_limit" => 4.765,
      "load_meterage_stackable_type" => "area",
      "load_meterage_non_stackable_type" => "ldm",
      "load_meterage_hard_limit" => false,
      "cbm_ratio" => 250.0,
      "scale" => "kg",
      "rate_basis" => "PER_SHIPMENT",
      "base" => 1.0,
      "truck_type" => "default",
      "load_type" => "cargo_item",
      "cargo_class" => "lcl",
      "direction" => "export",
      "carrier" => "Gateway Cargo GmbH",
      "service" => "standard",
      "group_id" => default_group.id,
      "identifier_modifier" => false,
      "mode_of_transport" => "truck_carriage",
      "effective_date" => today,
      "expiration_date" => today + 1.year }
  end
  let(:today) { Time.zone.today }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:default_group) { FactoryBot.create(:groups_group, name: "default", organization: organization) }

  before do
    Organizations.current_id = organization.id
  end

  describe ".sanitize" do
    it "sanitizes each value correctly", :aggregate_failures do
      frame_data.each do |attribute, value|
        sanitized_value = described_class.sanitize(value: value, attribute: attribute)
        expect(sanitized_value).to eq(expected_results[attribute])
      end
    end
  end
end
