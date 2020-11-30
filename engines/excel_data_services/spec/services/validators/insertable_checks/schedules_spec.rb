# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Validators::InsertableChecks::Schedules do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:options) { {organization: organization, sheet_name: "Sheet1", data: input_data} }

  context "with faulty data" do
    let(:input_data) do
      [{
        from: "DALIAN",
        to: "FELIXSTOWE",
        closing_date: "2020/01/01",
        etd: "2020/01/04",
        eta: "2020/02/11",
        transit_time: 38,
        carrier: "MSC",
        service_level: "Standard ",
        vessel: "Cap San Diego",
        voyage_code: "1010101",
        load_type: "fcl",
        row_nr: 2
      },
        {
          from: "DALIAN",
          to: "FELIXSTOWE",
          closing_date: "2020/01/01",
          eta: "2020/01/04",
          etd: "2020/02/11",
          transit_time: 38,
          carrier: nil,
          service_level: "Standard ",
          vessel: "Cap San Diego",
          voyage_code: "1010101",
          load_type: "fcl",
          row_nr: 3
        }].map { |row| ExcelDataServices::Rows::Schedules.new(organization: organization, row_data: row) }
    end

    describe ".validate" do
      it "logs the errors" do
        validator = described_class.new(options)
        validator.perform
        expect(validator.results).to match_array(
          [
            {exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
             reason: "There exists no carrier called 'MSC'.",
             row_nr: 2,
             sheet_name: "Sheet1",
             type: :error},
            {exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
             reason: "There exists no service level called 'Standard ' for carrier 'MSC'",
             row_nr: 2,
             sheet_name: "Sheet1",
             type: :error},
            {exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
             reason: "There exists no service level called 'Standard '.",
             row_nr: 3,
             sheet_name: "Sheet1",
             type: :error},
            {exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
             reason: "The dates provided are not in chronological order.",
             row_nr: 3,
             sheet_name: "Sheet1",
             type: :error}
          ]
        )
      end
    end
  end
end
