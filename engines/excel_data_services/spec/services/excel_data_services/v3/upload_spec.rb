# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Upload do
  include_context "V3 setup"
  let(:service) { described_class.new(file: file, arguments: arguments) }
  let(:arguments) { {} }

  before do
    Organizations.current_id = organization.id
  end

  describe "#valid?" do
    context "when the sheet type is recognised" do
      it "returns true when the sheet is pricings sheet" do
        expect(service.valid?).to eq(true)
      end
    end

    context "when the sheet type is not recognised" do
      let(:xlsx) { File.open(file_fixture("dummy.xlsx")) }

      it "returns false when the sheet is a trucking sheet" do
        expect(service.valid?).to eq(false)
      end
    end
  end

  describe "#perform" do
    let(:dummy_state) { instance_double("ExcelDataServices::V3::State", stats: [stat], errors: []) }
    let(:stat) { FactoryBot.build(:excel_data_services_stats) }
    let(:email_formatted_stats) do
      {
        pricings: { created: 1, failed: 0 },
        errors: []
      }
    end

    before do
      allow(service).to receive(:result_state).and_return(dummy_state)
    end

    it "returns the stats object formatted for the upload email" do
      expect(service.perform).to eq(email_formatted_stats)
    end
  end

  describe "#schema_types" do
    it "returns supported V3 schema types" do
      expect(service.schema_types).to match(%w[SacoPricings Pricings Schedules LocalCharges Hubs Clients Truckings])
    end

    context "with disabled uploaders option" do
      let(:arguments) { { disabled_uploaders: %w[SacoPricings Pricings] } }

      it "returns only enabled uploaders" do
        expect(service.schema_types).to match(%w[Schedules LocalCharges Hubs Clients Truckings])
      end
    end
  end
end
