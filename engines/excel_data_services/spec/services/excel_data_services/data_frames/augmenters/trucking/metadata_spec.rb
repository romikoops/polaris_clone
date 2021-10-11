# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Augmenters::Trucking::Metadata do
  include_context "with standard trucking setup"
  include_context "with trucking_metadata_sheet"

  before do
    Organizations.current_id = organization.id
  end

  describe ".frame" do
    before { described_class.state(state: trucking_metadata_state) }

    let(:carrier_code) { carrier_name.downcase }

    it "creates a TenantVehicle" do
      expect(
        Legacy::TenantVehicle.joins(:carrier)
          .find_by(name: "standard", organization: organization, mode_of_transport: "truck_carriage", carriers: { code: carrier_code })
      ).to be_present
    end

    it "creates a Legacy::Carrier" do
      expect(Legacy::Carrier.find_by(code: carrier_code)).to be_present
    end

    it "creates a Routing::Carrier" do
      expect(Routing::Carrier.find_by(code: carrier_code)).to be_present
    end
  end
end
