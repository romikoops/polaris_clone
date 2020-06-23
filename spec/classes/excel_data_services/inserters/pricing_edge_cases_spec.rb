# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Inserters::Pricing do
  include_context "false_itinerary"

  let!(:itinerary) { create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:tenants_tenant) { ::Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:tenant_vehicle) do
    create(:tenant_vehicle, tenant: tenant)
  end
  let(:options) { {tenant: tenant, data: input_data, options: {}} }
  let(:stats) { described_class.insert(options) }
  let!(:expected_stats) do
    {"legacy/itineraries": {number_created: 0, number_updated: 0, number_deleted: 0},
     "pricings/pricings": {number_created: 1, number_deleted: 0, number_updated: 0},
     "pricings/fees": {number_created: 1, number_deleted: 0, number_updated: 0},
     errors: []}
  end

  before do
    create(:tenants_scope, target: tenants_tenant, content: {"base_pricing" => true})
  end

  describe ".insert with two identical names" do
    let(:input_data) do
      [
        [{sheet_name: "Sheet1",
          restructurer_name: "pricing_one_fee_col_and_ranges",
          effective_date: Date.parse("Thu, 15 Mar 2018"),
          expiration_date: Date.parse("Fri, 15 Nov 2019"),
          customer_email: nil,
          origin: "Gothenburg",
          country_origin: "Sweden",
          destination: "Shanghai",
          country_destination: "China",
          mot: "ocean",
          carrier: nil,
          service_level: "standard",
          load_type: "lcl",
          rate_basis: "PER_WM",
          fee_code: "BAS",
          fee_name: "Bas",
          currency: "USD",
          fee_min: 17,
          fee: 17,
          transit_time: 24,
          transshipment: nil,
          row_nr: 2,
          internal: false,
          origin_name: "Gothenburg Port",
          destination_name: "Shanghai Port"}]
      ]
    end

    it "attaches the pricing to the correct itinerary" do
      aggregate_failures do
        expect(stats).to eq(expected_stats)
        expect(itinerary.rates.count).to eq(1)
        expect(faux_itinerary.rates).to be_empty
      end
    end
  end

  describe ".insert notes" do
    let(:input_data) do
      [
        [{sheet_name: "Sheet1",
          restructurer_name: "pricing_one_fee_col_and_ranges",
          effective_date: Date.parse("Thu, 15 Mar 2018"),
          expiration_date: Date.parse("Fri, 15 Nov 2019"),
          customer_email: nil,
          origin: "Gothenburg",
          country_origin: "Sweden",
          destination: "Shanghai",
          country_destination: "China",
          mot: "ocean",
          carrier: nil,
          service_level: "standard",
          load_type: "lcl",
          rate_basis: "PER_WM",
          fee_code: "BAS",
          fee_name: "Bas",
          currency: "USD",
          fee_min: 17,
          fee: 17,
          transit_time: 24,
          transshipment: nil,
          row_nr: 2,
          internal: false,
          notes: [
            {header: "Electronic Cargo Tracking Note/Waiver (Ectn/Besc)",
             body: nil,
             remarks: false,
             transshipment: false},
            {header: "Remarks", body: "some remark", remarks: true, transshipment: false}
          ],
          origin_name: "Gothenburg Port",
          destination_name: "Shanghai Port"}]
      ]
    end

    it "creates notes attached to the pricings" do
      aggregate_failures do
        expect(stats).to eq(expected_stats)
        expect(Legacy::Note.where.not(pricings_pricing_id: nil).count).to eq(2)
      end
    end
  end
end
