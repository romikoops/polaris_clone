# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Validators::SequentialDates do
  include_context "for excel_data_services setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:charge_category) { FactoryBot.create(:legacy_charge_categories, organization: organization) }

  describe ".state" do
    context "when the dates are sequential" do
      let(:row) do
        {
          "row" => 1,
          "effective_date" => Time.zone.today.to_date,
          "expiration_date" => Time.zone.tomorrow.to_date,
          "sheet_name" => "Sheet1"
        }
      end

      it "does not append any errors to the state" do
        expect(result.errors).to be_empty
      end
    end

    context "when the dates are out of order" do
      let(:row) do
        {
          "row" => 1,
          "effective_date" => Time.zone.tomorrow.to_date,
          "expiration_date" => Time.zone.yesterday.to_date,
          "sheet_name" => "Sheet1"
        }
      end

      let(:error_messages) do
        ["The expiration date ('#{row['expiration_date']}) lies before the effective date ('#{row['effective_date']})."]
      end

      it "appends an error to the state", :aggregate_failures do
        expect(result.errors).to be_present
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end
  end
end
