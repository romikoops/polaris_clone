# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Inserters::Pricing do
  include_context "false_itinerary"

  let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:tenant_vehicle) do
    FactoryBot.create(:legacy_tenant_vehicle, organization: organization)
  end
  let(:options) { { organization: organization, data: input_data, options: {} } }
  let(:stats) { described_class.insert(options) }
  let!(:expected_stats) do
    { "legacy/itineraries": { number_created: 0, number_updated: 0, number_deleted: 0 },
      "pricings/pricings": { number_created: 1, number_deleted: 0, number_updated: 0 },
      "pricings/fees": { number_created: 1, number_deleted: 0, number_updated: 0 },
      errors: [] }
  end

  before { FactoryBot.create(:groups_group, :default, organization: organization) }

  describe ".insert" do
    context "with two identical names" do
      let(:input_data) { FactoryBot.build(:excel_data_restructured_same_name_pricing) }

      it "attaches the pricing to the correct itinerary", :aggregate_failures do
        expect(stats).to eq(expected_stats)
        expect(itinerary.rates.count).to eq(1)
        expect(faux_itinerary.rates).to be_empty
      end
    end

    context "with notes" do
      let(:input_data) { FactoryBot.build(:excel_data_restructured_pricing_with_notes) }

      it "creates notes attached to the pricings", :aggregate_failures do
        expect(stats).to eq(expected_stats)
        expect(Legacy::Note.where.not(pricings_pricing_id: nil).count).to eq(2)
      end
    end

    context "with group name" do
      let(:input_data) { FactoryBot.build(:excel_data_restructured_pricing_with_group_name) }

      before { FactoryBot.create(:groups_group, name: "Test", organization: organization) }

      it "creates notes attached to the pricings" do
        expect(stats).to eq(expected_stats)
      end
    end

    context "with group id" do
      let(:input_data) { FactoryBot.build(:excel_data_restructured_pricing_with_group_name) }
      let(:group) { FactoryBot.create(:groups_group, name: "Test", organization: organization) }

      before { input_data.each { |data| data.first[:group_id] = group.id } }

      it "creates notes attached to the pricings" do
        expect(stats).to eq(expected_stats)
      end
    end

    context "with terminals" do
      let(:input_data) { FactoryBot.build(:excel_data_restructured_pricing_with_terminal) }
      let(:origin_hub) { FactoryBot.create(:gothenburg_hub, terminal: "1-A", organization: organization) }
      let(:destination_hub) { FactoryBot.create(:shanghai_hub, terminal: "A-1", organization: organization) }

      before { FactoryBot.create(:legacy_itinerary, origin_hub: origin_hub, destination_hub: destination_hub, organization: organization) }

      it "creates notes attached to the pricings" do
        expect(stats).to eq(expected_stats)
      end
    end

    context "when creating Legacy and Routing Carrier's in tandem" do
      it "ensures there is a Routing::Carrier for every Legacy::Carrier" do
        expect(Routing::Carrier.all.pluck(:code)).to eq(Legacy::Carrier.all.pluck(:code))
      end
    end
  end
end
