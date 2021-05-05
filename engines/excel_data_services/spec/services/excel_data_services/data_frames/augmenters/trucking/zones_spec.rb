# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Augmenters::Trucking::Zones do
  include_context "with standard trucking setup"
  include_context "with trucking_zones_sheet"
  let(:zone_type) { :zipcode }
  let(:trucking_zones_frame) { Rover::DataFrame.new(rows) }
  let(:country) { FactoryBot.create(:legacy_country, code: "ZA") }
  let(:postal_codes) { %w[20457 20458] }
  let(:rows) do
    postal_codes.map do |postal_code|
      { "sheet_name" => "Zones", "zone" => 1.0, "primary" => postal_code, "secondary" => nil, "country_code" => country.code, "identifier" => "zipcode", "query_method" => "postal_code" }
    end
  end

  before do
    Organizations.current_id = organization.id
  end

  describe ".frame" do
    shared_examples_for "Trucking::Locations are present" do
      it "alll necessary trucking_locations are there in the database" do
        expect(Trucking::Location.all.pluck(:data)).to match_array(postal_codes)
      end
    end

    context "when locations do not exists" do
      before { described_class.state(state: trucking_zones_state) }

      it_behaves_like "Trucking::Locations are present"
    end

    context "when locations do exist" do
      before do
        rows.each do |row|
          FactoryBot.create(:trucking_location, data: row["primary"], query: row["query_method"], location_id: nil, country: country)
        end

        described_class.state(state: trucking_zones_state)
      end

      it_behaves_like "Trucking::Locations are present"
    end
  end
end
