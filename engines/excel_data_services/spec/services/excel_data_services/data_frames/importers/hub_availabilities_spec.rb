# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Importers::HubAvailabilities do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:hub) { FactoryBot.create(:legacy_hub, organization: organization) }
  let(:type_availability) { FactoryBot.create(:trucking_type_availability) }
  let(:data) do
    Rover::DataFrame.new([{ type_availability_id: type_availability.id, hub_id: hub.id }])
  end
  let(:options) { { organization: organization, data: data, options: {} } }
  let(:stats) { described_class.import(data: data, type: "hub_availabilities") }

  describe ".import" do
    context "when no hub availabilities exist" do
      it "successfuly imports the data" do
        expect(stats.created).to eq(1)
      end
    end

    context "when hub availabilities exist" do
      before do
        FactoryBot.create(:trucking_hub_availability, type_availability_id: type_availability.id, hub_id: hub.id)
      end

      it "successfuly upserts the data" do
        expect(stats.created).to eq(0)
      end
    end
  end
end
