# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Import do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:stats) { described_class.import(model: model, data: data, type: type, options: options) }
  let(:options) { {} }
  let(:model) { Legacy::ChargeCategory }
  let(:type) { "charge_categories" }
  let(:data) do
    [{
      "code" => "bas",
      "name" => "Basic Freight",
      "organization_id" => organization.id
    }]
  end

  before do
    Organizations.current_id = organization.id
  end

  describe "#perform" do
    context "when inserting is successful" do
      it "returns a DataFrame of extracted values", :aggregate_failures do
        expect(stats.created).to eq(1)
      end
    end

    context "when inserting encounters a validation error" do
      let(:data) do
        [{
          "code" => "bas",
          "name" => "Basic Freight",
          "organization_id" => organization.id
        }, {
          "code" => "bas",
          "name" => "Basic_Freight",
          "organization_id" => organization.id
        }]
      end
      let(:options) { { on_duplicate_key_ignore: false } }

      it "returns a DataFrame of extracted values" do
        expect(stats.failed).to eq(2)
      end
    end

    context "when inserting encounters an unexpected error" do
      before { allow(model).to receive(:import).and_raise(ActiveRecord::StatementInvalid) }

      it "catches the error and returns a default set of Stats", :aggregate_failures do
        expect(stats.failed).to eq(1)
        expect(stats.errors.pluck(:reason)).to include("We were not able to insert your Charge categories correctly.")
      end
    end

    context "when data includes records to be updated as well as created" do
      let(:options) { { on_duplicate_key_ignore: false, on_duplicate_key_update: [:duration], validate: true } }
      let(:model) { Legacy::TransitTime }
      let(:type) { "transit_times" }
      let!(:existing_record) { FactoryBot.create(:legacy_transit_time, duration: 5) }
      let(:data) do
        [
          {
            "id" => nil,
            "itinerary_id" => FactoryBot.create(:legacy_itinerary).id,
            "tenant_vehicle_id" => FactoryBot.create(:legacy_tenant_vehicle).id,
            "duration" => 5
          },
          {
            "id" => existing_record.id,
            "itinerary_id" => existing_record.itinerary_id,
            "tenant_vehicle_id" => existing_record.tenant_vehicle_id,
            "duration" => 10
          }
        ]
      end

      it "successfully inserts the new record" do
        expect { stats }.to change(Legacy::TransitTime, :count).by(1)
      end

      it "successfully updates the existing one" do
        stats
        expect(existing_record.reload.duration).to eq(10)
      end
    end

    context "when data includes records to be updated as well as created, and one invalid record" do
      let(:options) { { on_duplicate_key_ignore: false, on_duplicate_key_update: [:duration], validate: true } }
      let(:model) { Legacy::TransitTime }
      let(:type) { "transit_times" }
      let!(:existing_record) { FactoryBot.create(:legacy_transit_time, duration: 5) }
      let(:data) do
        [
          {
            "id" => nil,
            "itinerary_id" => FactoryBot.create(:legacy_itinerary).id,
            "tenant_vehicle_id" => FactoryBot.create(:legacy_tenant_vehicle).id,
            "duration" => 5
          },
          {
            "id" => existing_record.id,
            "itinerary_id" => existing_record.itinerary_id,
            "tenant_vehicle_id" => existing_record.tenant_vehicle_id,
            "duration" => 10
          },
          {
            "id" => nil,
            "itinerary_id" => nil,
            "tenant_vehicle_id" => existing_record.tenant_vehicle_id,
            "duration" => 10
          }
        ]
      end

      it "successfully inserts the new record" do
        expect { stats }.to change(Legacy::TransitTime, :count).by(1)
      end

      it "successfully updates the existing one" do
        stats
        expect(existing_record.reload.duration).to eq(10)
      end
    end
  end
end
