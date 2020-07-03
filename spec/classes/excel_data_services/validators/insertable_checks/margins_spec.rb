# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Validators::InsertableChecks::Margins do
  let(:organization) { create(:organizations_organization) }
  let(:user) { create(:organizations_user, organization: organization) }
  let(:options) do
    {
      organization: organization,
      data: input_data,
      sheet_name: 'Margins',
      options: {
        applicable: user
      }
    }
  end
  let(:tenant_vehicle) do
    create(:tenant_vehicle,
           organization: organization,
           name: 'standard',
           carrier: build(:carrier, code: 'consolidation', name: 'Consolidation'))
  end

  before do
    itinerary = create(:itinerary, name: 'Dalian - Gothenburg', organization: organization)
    create(:pricings_margin,
           organization: organization,
           applicable: user,
           itinerary: itinerary,
           cargo_class: 'lcl',
           tenant_vehicle: tenant_vehicle,
           effective_date: Date.parse('Tue, 01 Jan 2019'),
           expiration_date: Date.parse('Sun, 31 Mar 2019'))
  end

  context 'with faulty data' do
    let(:input_data) { build(:excel_data_restructured_faulty_margins) }

    describe '.validate' do
      it 'logs the errors' do
        validator = described_class.new(options)
        validator.perform
        expect(validator.results).to eq(
          [{
            type: :warning,
            row_nr: 2,
            sheet_name: "Margins",
            reason:
            "There exist margins (in the system or this file) with an overlapping effective period.\n(Old is covered by new: [2019-01-01 00:00 - 2019-03-31 00:00] <-> [2019-01-01 00:00 - 2019-03-31 23:59]).",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks},
          {
            type: :error,
            row_nr: 3,
            sheet_name: "Margins",
            reason: "No Itinerary can be found with the name Dalian - Gothenburg (air).",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks},
          {
            type: :warning,
            row_nr: 3,
            sheet_name: "Margins",
            reason: "There is specified service level does not exist in the database.\nfast - Consolidation.",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks}]
        )
      end
    end
  end
end
