# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admiralty::LocationImporter, type: :service do
  let!(:country) { FactoryBot.create(:legacy_country, code: "AF") }
  let(:data) do
    'postcode,id,country,coordinates,geometry
    5000,8d6343df-19d6-544a-9f2a-4290c3f19ab9,AF,POINT (69.0693045621873 34.499513939273),"POLYGON ((69.09998881952579 34.49152772657233, 69.06463561361379 34.52116876853731, 69.06934033029498 34.35054765752549, 69.12291522823884 34.35339892529914, 69.09998881952579 34.49152772657233))"'
  end
  let(:file) do
    Tempfile.new("test").tap do |tmp_file|
      tmp_file.write(data)
      tmp_file.rewind
    end
  end
  let(:service) { described_class.new(country: country, file: file) }

  after { file.unlink }

  describe ".data" do
    context "when data is not present" do
      before { service.perform }

      it "returns a the clients count for the time period", :aggregate_failures do
        expect(Trucking::Location.where(country: country).count).to eq(1)
        expect(Locations::Location.where(country_code: country.code.downcase).count).to eq(1)
      end
    end

    context "when data is present" do
      let!(:trucking_location) { FactoryBot.create(:trucking_location, country: country, data: "5000", query: :location) }
      let!(:locations_location) { FactoryBot.create(:locations_location, country_code: country.code, name: "5000") }

      it "updates the bounds of the existsing Locations::Location", :aggregate_failures do
        expect { service.perform }.not_to change(locations_location, :bounds)
      end

      it "does not update the Trucking::Location", :aggregate_failures do
        expect { service.perform }.not_to change(trucking_location, :inspect)
      end
    end
  end
end
