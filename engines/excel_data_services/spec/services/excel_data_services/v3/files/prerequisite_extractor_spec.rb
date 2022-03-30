# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Files::PrerequisiteExtractor do
  include_context "V3 setup"

  let(:result) { described_class.new(parent: "Pricings").dependencies }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:sheet_type) { FactoryBot.build(:excel_data_services_files_sheet_type, file: file, organization: organization) }

  before do
    Organizations.current_id = organization.id
  end

  describe "#dependencies" do
    it "returns the section in order of dependecy" do
      expect(result).to eq(%w[RoutingCarrier Carrier TenantVehicle Itinerary ChargeCategory TransitTime Pricings])
    end
  end
end
