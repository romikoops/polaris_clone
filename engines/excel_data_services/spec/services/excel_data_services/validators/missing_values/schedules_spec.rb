# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Validators::MissingValues::Schedules do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:options) { { organization: organization, sheet_name: "Sheet1", data: input_data } }

  context "with faulty data" do
    let(:input_data) do
      [{
        from: nil,
        to: nil,
        closing_date: nil,
        etd: nil,
        eta: nil,
        transit_time: nil,
        mode_of_transport: nil,
        carrier: nil,
        service_level: nil,
        vessel: nil,
        voyage_code: nil,
        load_type: nil,
        row_nr: 2
      }].map { |row| ExcelDataServices::Rows::Schedules.new(organization: organization, row_data: row) }
    end

    describe ".validate" do
      let(:errors) do
        %i[eta etd closing_date mode_of_transport from to load_type].map do |error_key|
          { exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues,
            reason: "Missing value for #{error_key.upcase}.",
            row_nr: 2,
            sheet_name: "Sheet1",
            type: :error }
        end
      end

      it "logs the errors" do
        validator = described_class.new(options)
        validator.perform
        expect(validator.results).to match_array(errors)
      end
    end
  end
end
