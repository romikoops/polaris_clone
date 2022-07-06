# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::DefaultTruckingDates do
  include_context "V4 setup"
  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }

  describe ".state" do
    context "when found" do
      let(:rows) do
        [
          {
            "effective_date" => nil,
            "expiration_date" => nil,
            "row" => 2,
            "organization_id" => organization.id
          },
          {
            "effective_date" => 1.week.ago.to_date,
            "expiration_date" => 3.months.from_now.to_date,
            "row" => 3,
            "organization_id" => organization.id
          }
        ]
      end

      it "returns the frame with the default effective and expiration_date added", :aggregate_failures do
        expect(extracted_table["effective_date"].to_a).to match_array([Time.zone.today, 1.week.ago.to_date])
        expect(extracted_table["expiration_date"].to_a).to match_array([1.year.from_now.to_date, 3.months.from_now.to_date])
      end
    end
  end
end
