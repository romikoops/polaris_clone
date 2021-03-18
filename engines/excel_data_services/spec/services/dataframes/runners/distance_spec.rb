# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Runners::Trucking do
  include_context "with standard trucking setup"
  include_context "with trucking_sheet"

  before do
    Organizations.current_id = organization.id
    stats_or_errors
  end

  let(:zone_type) { :distance }
  let(:query_method) { "distance" }
  let(:country_code) { "ZA" }
  let(:truckings) { ::Trucking::Trucking.all }
  let(:trucking_hub_availabilities) { ::Trucking::HubAvailability.all }
  let(:trucking_type_availabilities) { ::Trucking::TypeAvailability.all }
  let(:trucking_type_availability) { trucking_type_availabilities.first }
  let(:stats_or_errors) { trucking_runner.perform }

  describe ".perform" do
    it "returns successfully", :aggregate_failures do
      expect(stats_or_errors.dig("truckings", "created")).to eq(101)
      expect(truckings.map { |tr| tr.rates.dig(modifiers.first.to_s).count }.uniq).to eq([bracket_counts.first])
      expect(truckings.map(&:modifier).uniq).to eq(modifiers)
    end

    it "creates the necessary HubAvailabilities", :aggregate_failures do
      expect(trucking_hub_availabilities.count).to eq(1)
    end

    it "creates the necessary TypeAvailabilities", :aggregate_failures do
      expect(trucking_type_availabilities.count).to eq(1)
      expect(trucking_type_availability.load_type).to eq("cargo_item")
      expect(trucking_type_availability.carriage).to eq("pre")
      expect(trucking_type_availability.country).to eq(country)
      expect(trucking_type_availability.query_method).to eq("distance")
    end
  end
end
