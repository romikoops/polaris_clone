# frozen_string_literal: true

require "rails_helper"

RSpec.describe DocumentService::ScheduleSheetWriter do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:schedule_headers) do
    %w[FROM TO CLOSING_DATE ETD ETA TRANSIT_TIME SERVICE_LEVEL CARRIER MODE_OF_TRANSPORT VESSEL VOYAGE_CODE LOAD_TYPE]
  end

  before do
    FactoryBot.create(:organizations_theme, organization: organization)
  end

  describe ".perform" do
    subject { described_class.new(organization_id: organization.id) }

    let(:xlsx) { Roo::Spreadsheet.open("tmp/#{subject.filename}") }
    let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }
    let!(:trip) { FactoryBot.create(:trip_with_layovers, itinerary: itinerary) }
    let(:schedule_row) do
      [
        "Gothenburg",
        "Shanghai",
        trip.layovers.first.closing_date.to_s,
        trip.layovers.first.etd.to_s,
        trip.layovers.last.eta.to_s,
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
