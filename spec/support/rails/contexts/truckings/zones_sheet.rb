# frozen_string_literal: true

RSpec.shared_context "with trucking_zones_sheet" do
  let(:zone_count) { 3 }
  let(:country_code) { "GB" }
  let(:zone_type) { :alphanumeric }
  let(:zone_schema) do
    FactoryBot.build(:schemas_sheets_trucking_zones, file: instance_double("xlsx"), sheet_name: "Zones")
  end
  let(:trucking_zones_frame) do
    FactoryBot.build(:trucking_zones_frame, zone_type, country_code: country_code)
  end
  let(:trucking_zones_state) do
    ExcelDataServices::DataFrames::Combinators::State.new(
      frame: trucking_zones_frame,
      schema: zone_schema,
      errors: [],
      hub_id: hub.id,
      group_id: group_id,
      organization_id: organization.id
    )
  end

  before do
    allow(ExcelDataServices::DataFrames::DataProviders::Trucking::Zones).to receive(:state)
      .and_return(trucking_zones_state)
  end
end
