# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::ModelInitializer do
  let(:organization) { FactoryBot.create(:organizations_organization) }

  let(:xlsx) { Roo::Spreadsheet.open(file_fixture("excel/example_pricings.xlsx").to_s) }
  let(:service) { described_class.new(model: model, data: data) }
  let(:result) { service.perform.first }
  let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:itinerary) { FactoryBot.create(:legacy_itinerary, organization: organization) }
  let(:charge_category) { FactoryBot.create(:legacy_charge_categories, organization: organization) }
  let(:rate_basis) { FactoryBot.create(:pricings_rate_basis) }
  let(:start_date) { Time.zone.tomorrow.to_date }
  let(:end_date) { start_date + 1.year }

  before do
    Organizations.current_id = organization.id
  end

  describe "#perform" do
    shared_examples_for "#perform" do
      it "returns a DataFrame of extracted values", :aggregate_failures do
        expect(result).to be_a(model)
        expect(result).not_to be_persisted
        expect(result).to be_valid
      end
    end

    context "when section is ChargeCategory" do
      let(:model) { Legacy::ChargeCategory }
      let(:data) do
        [{
          "code" => "bas",
          "name" => "Basic Freight",
          "organization_id" => organization.id
        }]
      end

      it_behaves_like "#perform"
    end

    context "when section is TenantVehicle" do
      let(:model) { Legacy::TenantVehicle }
      let(:data) do
        [{
          "name" => "standard",
          "carrier_id" => FactoryBot.create(:legacy_carrier).id,
          "mode_of_transport" => "ocean",
          "organization_id" => organization.id
        }]
      end

      it_behaves_like "#perform"
    end

    context "when section is Carrier" do
      let(:model) { Legacy::Carrier }
      let(:data) do
        [{
          "name" => "MSC",
          "code" => "msc"
        }]
      end

      it_behaves_like "#perform"
    end

    context "when section is Itinerary" do
      let(:model) { Legacy::Itinerary }
      let(:data) do
        [{ "origin_hub_id" => itinerary.origin_hub_id,
           "destination_hub_id" => itinerary.destination_hub_id,
           "mode_of_transport" => "air",
           "transshipment" => nil,
           "organization_id" => organization.id,
           "name" => "Gothenburg - Shanghai",
           "stops" => [
             { "hub_id" => itinerary.origin_hub_id, "index" => 0 },
             { "hub_id" => itinerary.destination_hub_id, "index" => 1 }
           ],
           "upsert_id" => "e412aa83-1fc6-5477-8442-18e26c834fb3" }]
      end

      it_behaves_like "#perform"
    end

    context "when section is Organization" do
      let(:model) { Organizations::Organization }
      let(:data) do
        [{ "slug" => "aaa",
           "theme" => {
             "primary_color" => "aaaaaa"
           } }]
      end

      it_behaves_like "#perform"
    end

    context "when section is Pricings" do
      let(:model) { Pricings::Pricing }
      let(:data) do
        [{ "cargo_class" => "lcl",
           "effective_date" => start_date,
           "expiration_date" => end_date,
           "vm_rate" => 1.0,
           "wm_rate" => 1.0,
           "group_id" => default_group.id,
           "itinerary_id" => itinerary.id,
           "tenant_vehicle_id" => tenant_vehicle.id,
           "organization_id" => organization.id,
           "transshipment" => nil,
           "fees" =>
            [{ "organization_id" => organization.id,
               "base" => nil,
               "charge_category_id" => charge_category.id,
               "rate_basis_id" => rate_basis.id,
               "rate" => 210.0,
               "currency_name" => "USD",
               "range" => [] }],
           "internal" => false,
           "load_type" => "cargo_item",
           "validity" => "[#{start_date}, #{end_date})",
           "upsert_id" => "ae71d529-8c65-5c9d-9629-67a03e7bc8e6" }]
      end

      it_behaves_like "#perform"
    end
  end
end
