# frozen_string_literal: true

RSpec.shared_context "with trucking_sheet" do
  include_context "with trucking_zones_sheet"
  include_context "with trucking_fees_sheet"
  include_context "with trucking_values_sheet"
  include_context "with trucking_brackets_sheet"
  include_context "with trucking_bracket_minimums_sheet"
  include_context "with trucking_zone_minimums_sheet"
  include_context "with trucking_modifiers_sheet"
  include_context "with trucking_metadata_sheet"
  include_context "with trucking_zone_rows_sheet"
  include_context "with trucking_country_codes_sheet"

  let(:fees) { [] }
  let(:zone_type) { :alphanumeric }
  let(:query_method) { "location" }
  let(:zone_count) { 6 }
  let(:bracket_counts) { [10] }
  let(:modifiers) { ["kg"] }
  let(:load_type) { "cargo_item" }
  let(:cargo_class) { "lcl" }
  let(:truck_type) { "default" }
  let(:country_code) { "GB" }
  let!(:default_group) { FactoryBot.create(:groups_group, name: "default", organization: organization) }
  let(:country) { FactoryBot.create(:legacy_country, code: country_code) }
  let(:trucking_file) { FactoryBot.build(:schemas_file_trucking, file: xlsx) }
  let(:trucking_runner) { FactoryBot.build(:runners_trucking, file: trucking_file, arguments: arguments) }
  let(:rate_schema) do
    FactoryBot.build(:schemas_sheets_trucking_rates, file: xlsx, sheet_name: "Rates")
  end

  before do
    tenant_vehicle
    country
    allow(trucking_file).to receive(:valid?).and_return(true)
    allow(fee_schema).to receive(:valid?).and_return(true)
    allow(zone_schema).to receive(:valid?).and_return(true)
    allow(rate_schema).to receive(:valid?).and_return(true)
    allow(trucking_file).to receive(:fee_schema).and_return(fee_schema)
    allow(trucking_file).to receive(:zone_schema).and_return(zone_schema)
    allow(trucking_file).to receive(:rate_schemas).and_return([rate_schema])
  end
end
