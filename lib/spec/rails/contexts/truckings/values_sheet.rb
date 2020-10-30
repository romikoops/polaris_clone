# frozen_string_literal: true

RSpec.shared_context "with trucking_values_sheet" do
  let(:rate_schema) do
    FactoryBot.build(:schemas_sheets_trucking_rates, file: instance_double("xlsx"), sheet_name: "Rates")
  end
  let(:zone_count) { 3 }
  let(:bracket_counts) { [10] }
  let(:value_override) { nil }
  let(:trucking_values_frame) do
    FactoryBot.build(:trucking_values_frame,
      zone_count: zone_count,
      bracket_counts: bracket_counts,
      value: value_override)
  end
  let(:trucking_values_state) do
    ExcelDataServices::DataFrames::Combinators::State.new(
      frame: trucking_values_frame,
      schema: rate_schema,
      errors: [],
      hub_id: hub.id,
      group_id: group_id,
      organization_id: organization.id
    )
  end

  before do
    allow(ExcelDataServices::DataFrames::DataProviders::Trucking::Values).to receive(:state)
      .and_return(trucking_values_state)
  end
end
