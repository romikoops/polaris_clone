# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Validators::SequentialDates do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }

  describe "#state" do
    described_class::DATE_PAIRS.each do |start_key, end_key|
      context "when the keys are #{start_key} and #{end_key}" do
        context "when the dates are sequential" do
          let(:row) do
            {
              "row" => 1,
              start_key => Time.zone.today.to_date,
              end_key => Time.zone.tomorrow.to_date,
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
              start_key => Time.zone.tomorrow.to_date,
              end_key => Time.zone.yesterday.to_date,
              "sheet_name" => "Sheet1"
            }
          end

          let(:error_messages) do
            ["The #{end_key.humanize} ('#{row[end_key]}) lies before the #{start_key.humanize} ('#{row[start_key]})."]
          end

          it "appends an error to the state", :aggregate_failures do
            expect(result.errors).to be_present
            expect(result.errors.map(&:reason)).to match_array(error_messages)
          end
        end
      end
    end
  end
end
