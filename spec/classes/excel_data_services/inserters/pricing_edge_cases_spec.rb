# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Inserters::Pricing do
  include_context "false_itinerary"

  let!(:itinerary) { create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:tenant_vehicle) do
    create(:tenant_vehicle, organization: organization)
  end
  let(:options) { {organization: organization, data: input_data, options: {}} }
  let(:stats) { described_class.insert(options) }
  let!(:expected_stats) do
    {"legacy/itineraries": {number_created: 0, number_updated: 0, number_deleted: 0},
     "pricings/pricings": {number_created: 1, number_deleted: 0, number_updated: 0},
     "pricings/fees": {number_created: 1, number_deleted: 0, number_updated: 0},
     errors: []}
  end

  before { FactoryBot.create(:groups_group, :default, organization: organization) }

  describe ".insert" do
    context "with two identical names" do
      let(:input_data) { FactoryBot.build(:excel_data_restructured_same_name_pricing) }

      it "attaches the pricing to the correct itinerary" do
        aggregate_failures do
          expect(stats).to eq(expected_stats)
          expect(itinerary.rates.count).to eq(1)
          expect(faux_itinerary.rates).to be_empty
        end
      end
    end

    context "with two identical names, different  locode" do
      let(:input_data) { FactoryBot.build(:excel_data_restructured_same_name_locode_pricing) }

      before do
        FactoryBot.create(:gothenburg_nexus, locode: nil).tap do |tapped_nexus|
          FactoryBot.create(:gothenburg_hub, nexus: tapped_nexus, hub_code: nil)
        end
      end

      it "attaches the pricing to the correct itinerary" do
        aggregate_failures do
          expect(stats).to eq(expected_stats)
          expect(itinerary.rates.count).to eq(1)
          expect(faux_itinerary.rates).to be_empty
        end
      end
    end

    context "with two identical locodes, different  names" do
      let(:input_data) { FactoryBot.build(:excel_data_restructured_same_locode_pricing) }
      let(:faux_origin_country) { FactoryBot.create(:country_se) }
      let(:faux_destination_country) { FactoryBot.create(:country_cn) }
      let(:faux_origin_name) { "Gothenburg - Key 4" }
      let(:faux_destination_name) { "Shanghai" }
      let(:faux_origin_locode) { "SEGOT" }
      let(:faux_destination_locode) { "CNSHA" }

      it "attaches the pricing to the correct itinerary" do
        aggregate_failures do
          expect(stats).to eq(expected_stats)
          expect(faux_itinerary.rates.count).to eq(1)
          expect(itinerary.rates).to be_empty
        end
      end
    end

    context "with notes" do
      let(:input_data) { FactoryBot.build(:excel_data_restructured_pricing_with_notes) }

      it "creates notes attached to the pricings" do
        aggregate_failures do
          expect(stats).to eq(expected_stats)
          expect(Legacy::Note.where.not(pricings_pricing_id: nil).count).to eq(2)
        end
      end
    end

    context "with group name" do
      let(:input_data) { FactoryBot.build(:excel_data_restructured_pricing_with_group_name) }

      before { FactoryBot.create(:groups_group, name: "Test", organization: organization) }

      it "creates notes attached to the pricings" do
        aggregate_failures do
          expect(stats).to eq(expected_stats)
        end
      end
    end

    context "with group id" do
      let(:input_data) { FactoryBot.build(:excel_data_restructured_pricing_with_group_name) }
      let(:group) { FactoryBot.create(:groups_group, name: "Test", organization: organization) }

      before { input_data.each { |data| data.first[:group_id] = group.id } }

      it "creates notes attached to the pricings" do
        aggregate_failures do
          expect(stats).to eq(expected_stats)
        end
      end
    end
  end
end
