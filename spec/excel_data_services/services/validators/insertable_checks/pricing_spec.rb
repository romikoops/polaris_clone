# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Validators::InsertableChecks::Pricing do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:options) { {organization: organization, sheet_name: "Sheet1", data: input_data} }
  let!(:pricings) do
    [
      FactoryBot.create(
        :lcl_pricing,
        organization: organization,
        effective_date: Date.parse("Thu, 15 Mar 2018").beginning_of_day,
        expiration_date: Date.parse("Sun, 17 Mar 2019").end_of_day.change(usec: 0),
        itinerary: itineraries.first,
        tenant_vehicle: tenant_vehicle
      )
    ]
  end
  let(:itineraries) do
    [
      FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization)
    ]
  end

  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier_id: nil, organization: organization) }

  context "with faulty data" do
    let(:group_a) { FactoryBot.build_stubbed(:groups_group, organization: organization, name: "GROUP A", id: "000-gr0up-a-id-123") }
    let(:input_data) { FactoryBot.build(:excel_data_restructured_faulty_pricings_one_fee_col_and_ranges) }
    let(:group_b) { FactoryBot.build_stubbed(:groups_group, organization: organization, name: "GROUP B", id: "000-gr0up-b-id-456") }

    before do
      allow(Groups::Group).to receive(:find_by).with(organization: organization, id: "other-000-gr0up-a-id-123")
      allow(Groups::Group).to receive(:find_by).with(organization: organization, name: "OTHER GROUP B")
      allow(Groups::Group).to receive(:find_by).with(organization: organization, id: "000-gr0up-a-id-123").and_return(group_a)
      allow(Groups::Group).to receive(:find_by).with(organization: organization, name: "GROUP B").and_return(group_b)
    end

    describe ".validate" do
      let(:expected_results) do
        [{type: :error, row_nr: 2,
          sheet_name: "Sheet1",
          reason: "Effective date must lie before before expiration date!",
          exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks},
          {type: :error,
           row_nr: 2,
           sheet_name: "Sheet1",
           reason: 'Hub "GothenERRORburg, Sweden" (Ocean) not found!',
           exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks},
          {type: :error,
           row_nr: 3,
           sheet_name: "Sheet1",
           reason: "The Group with ID 'other-000-gr0up-a-id-123' does not exist!",
           exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks},
          {type: :warning,
           row_nr: 3,
           sheet_name: "Sheet1",
           reason: "There exist rates (in the system or this file) with an overlapping effective period.\n(Old is covered by new: [2018-03-15 00:00 - 2019-03-17 23:59] <-> [2018-03-15 00:00 - 2019-03-17 23:59]).",
           exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks},
          {type: :error,
           row_nr: 3,
           sheet_name: "Sheet1",
           reason: "The Group with name 'OTHER GROUP B' does not exist!",
           exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks},
          {type: :error,
           row_nr: 3,
           sheet_name: "Sheet1",
           reason: "The Group with ID '000-gr0up-a-id-123' is not the same as the group with name 'GROUP B'!",
           exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks}]
      end

      it "logs the errors" do
        validator = described_class.new(options)
        validator.perform
        expect(validator.results).to match_array(expected_results)
      end
    end
  end
end
