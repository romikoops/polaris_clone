# frozen_string_literal: true

RSpec.shared_context "with trucking_country_codes_sheet" do
  let(:zone_count) { 3 }
  let(:country_code) { "GB" }
  let(:query_method) { "location" }
  let(:zone_schema) do
    FactoryBot.build(:schemas_sheets_trucking_zones, file: instance_double("xlsx"), sheet_name: "Zones")
  end
  let(:trucking_country_codes_frame) do
    FactoryBot.build(:trucking_country_codes_frame,
      query_method: query_method,
      zone_count: zone_count,
      country_code: country_code)
  end
  let(:trucking_country_codes_state) do
    ExcelDataServices::DataFrames::Combinators::State.new(
      frame: trucking_country_codes_frame,
      schema: zone_schema,
      errors: [],
      hub_id: hub.id,
      group_id: group_id,
      organization_id: organization.id
    )
  end

  before do
    allow(ExcelDataServices::DataFrames::DataProviders::Trucking::CountryCodes).to receive(:state)
      .and_return(trucking_country_codes_state)
  end
end
