# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Extractors::TenantVehicle do
  include_context "with standard trucking setup"

  let(:target_schema) { nil }
  let(:result) { described_class.state(state: combinator_arguments) }
  let(:extracted_table) { result.frame }
  let(:frame) { Rover::DataFrame.new([row]) }
  let(:row) { { service: "standard", carrier: "SACO", mode_of_transport: "truck_carriage" }.stringify_keys }
  let(:carrier) { FactoryBot.create(:legacy_carrier, name: "SACO") }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:tenant_vehicle) do
    FactoryBot.create(:legacy_tenant_vehicle,
      organization: organization,
      carrier: carrier,
      mode_of_transport: "truck_carriage")
  end

  before do
    Organizations.current_id = organization.id
  end

  describe ".data" do
    it "returns the frame with the tenant_vehicle_id" do
      expect(extracted_table["tenant_vehicle_id"].to_a).to eq([tenant_vehicle.id])
    end
  end
end
