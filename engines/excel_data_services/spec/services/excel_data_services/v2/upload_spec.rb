# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Upload do
  include_context "for excel_data_services setup"
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
      let(:xlsx) { File.open(file_fixture("excel/example_trucking.xlsx")) }

      it "returns false when the sheet is a trucking sheet" do
        expect(service.valid?).to eq(false)
      end
    end
  end

  describe "#perform" do
    let(:dummy_state) { instance_double("ExcelDataServices::V2::State", stats: [stat], errors: []) }
    let(:stat) { FactoryBot.build(:excel_data_services_stats) }
    let(:email_result) do
      {
        pricings: { created: 1, failed: 0 },
        errors: []
      }
    end

    before do
      allow(service).to receive(:result_state).and_return(dummy_state)
    end

    it "triggers returns the stats object from the result_state" do
      expect(service.perform).to eq(email_result)
    end
  end
end
