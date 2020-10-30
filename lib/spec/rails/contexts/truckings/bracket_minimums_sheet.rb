# frozen_string_literal: true

RSpec.shared_context "with trucking_bracket_minimums_sheet" do
  let(:rate_schema) do
    FactoryBot.build(:schemas_sheets_trucking_rates, file: instance_double("xlsx"), sheet_name: "Rates")
  end
  let(:bracket_counts) { [10] }
  let(:bracket_minimum) { 25 }
  let(:trucking_bracket_minimums_frame) do
    FactoryBot.build(:trucking_bracket_minimums_frame,
      bracket_counts: bracket_counts,
      minimum: bracket_minimum)
  end
  let(:trucking_bracket_minimums_state) do
    ExcelDataServices::DataFrames::Combinators::State.new(
      frame: trucking_bracket_minimums_frame,
      schema: rate_schema,
      errors: [],
      hub_id: hub.id,
      group_id: group_id,
      organization_id: organization.id
    )
  end

  before do
    allow(ExcelDataServices::DataFrames::DataProviders::Trucking::BracketMinimum).to receive(:state)
      .and_return(trucking_bracket_minimums_state)
  end
end
