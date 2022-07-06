# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Upload do
  include_context "V4 setup"
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
    let(:dummy_state) { instance_double("ExcelDataServices::V4::State", stats: [stat], errors: []) }
    let(:stat) { ExcelDataServices::V4::Stats.new(type: "pricings", created: 1, failed: 0, errors: []) }
    let(:email_formatted_stats) do
      {
        pricings: { created: 1, failed: 0 },
        errors: [],
        warnings: []
      }
    end

    before do
      allow(service).to receive(:result_state).and_return(dummy_state)
    end

    it "returns the stats object formatted for the upload email" do
      expect(service.perform).to eq(email_formatted_stats)
    end
  end

  describe "#filtered_schema_types" do
    all_schema_types = %w[
      hubs
      clients
      grdb_xml_origin_charge
      schedules
      pricings
      grdb_excel
      trucking
      saco_import
      saco_pricings
      grdb_xml_destination_charge
      grdb_xml
      local_charge
    ]

    it "returns supported V4 schema types" do
      expect(service.filtered_schema_types).to match_array(all_schema_types)
    end

    context "with disabled uploaders option" do
      let(:arguments) { { disabled_uploaders: %w[saco_pricings pricings] } }

      it "returns only enabled uploaders" do
        expect(service.filtered_schema_types).to match_array(all_schema_types - %w[saco_pricings pricings])
      end
    end
  end
end
