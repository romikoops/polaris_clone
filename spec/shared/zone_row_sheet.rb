# frozen_string_literal: true

RSpec.shared_context "with trucking_zone_rows_sheet" do
  let(:rate_schema) do
    FactoryBot.build(:schemas_sheets_trucking_rates, file: instance_double("xlsx"), sheet_name: "Rates")
  end
  let(:zone_counts) { 3 }
  let(:trucking_zone_rows_frame) do
    FactoryBot.build(:trucking_zone_rows_frame, zone_count: zone_count)
  end
  let(:trucking_zone_rows_state) do
    ExcelDataServices::DataFrames::Combinators::State.new(
      frame: trucking_zone_rows_frame,
      schema: rate_schema,
      errors: [],
      hub_id: hub.id,
      group_id: group_id,
      organization_id: organization.id
    )
  end

  before do
    allow(ExcelDataServices::DataFrames::DataProviders::Trucking::ZoneRow).to receive(:state)
      .and_return(trucking_zone_rows_state)
  end
end
