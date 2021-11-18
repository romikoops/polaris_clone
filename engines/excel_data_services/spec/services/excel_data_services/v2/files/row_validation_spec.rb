# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Files::RowValidation do
  include_context "for excel_data_services setup"

  let(:result) { described_class.new(keys: keys, comparator: comparator).state(state: state_arguments) }
  let(:errors) { result.errors }
  let(:charge_category) { FactoryBot.create(:legacy_charge_categories, organization: organization) }

  before do
    Organizations.current_id = organization.id
  end

  describe ".state" do
    shared_examples_for "a passing validation" do
      it "appends no errors to the state" do
        expect(result.errors).to be_empty
      end
    end

    shared_examples_for "a failing validation" do
      it "appends the expected error to the state", :aggregate_failures do
        expect(result.errors.map(&:reason)).to match_array([expected_error_reason])
        expect(result.errors.map(&:row_nr)).to match_array([row["row"]])
      end
    end

    context "when checking effective dates are before expiration dates and it passes" do
      let(:row) do
        {
          "row" => 1, "effective_date" => Time.zone.today.to_date, "expiration_date" => Time.zone.tomorrow.to_date, "sheet_name" => "Sheet1"
        }
      end
      let(:comparator) { proc { |a, b| a < b } }
      let(:keys) { %w[effective_date expiration_date] }

      it_behaves_like "a passing validation"
    end

    context "when checking effective dates are before expiration dates and it fails" do
      let(:row) do
        {
          "row" => 1, "effective_date" => Time.zone.today.to_date, "expiration_date" => Time.zone.today.to_date, "sheet_name" => "Sheet1"
        }
      end
      let(:comparator) { proc { |a, b| a < b } }
      let(:keys) { %w[effective_date expiration_date] }
      let(:expected_error_reason) { "The values in columns #{keys.join(',')} in row #{row['row']} on sheet #{row['sheet_name']} are invalid - please check them before reuploading." }

      it_behaves_like "a failing validation"
    end
  end
end
