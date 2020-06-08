# frozen_string_literal: true

require "rails_helper"

RSpec.describe DocumentService::ScheduleSheetWriter do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:schedule_headers) do
    %w[FROM TO CLOSING_DATE ETD ETA TRANSIT_TIME SERVICE_LEVEL CARRIER MODE_OF_TRANSPORT VESSEL VOYAGE_CODE LOAD_TYPE]
  end

  describe ".perform" do
    subject { described_class.new(tenant_id: tenant.id) }

    let(:xlsx) { Roo::Spreadsheet.open("tmp/#{subject.filename}") }
    let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }
    let(:schedule_row) do
      [
        "Gothenburg",
        "Shanghai",
        "2020-06-13 05:00:00 UTC",
        "2020-06-15 00:00:00 UTC",
        "2020-06-29 00:00:00 UTC",
        14,
        "standard",
        nil,
        "ocean",
        nil,
        nil,
        "cargo_item"
      ]
    end

    before do
      FactoryBot.create(:trip_with_layovers, itinerary: itinerary)
      allow(subject).to receive(:write_to_aws).and_return("http://AWS")

      subject.perform
    end

    it "writes all pricings to the sheet" do
      aggregate_failures "testing sheet values" do
        expect(first_sheet.row(1)).to eq(schedule_headers)
        expect(first_sheet.row(2)).to eq(schedule_row)
      end
    end
  end
end
