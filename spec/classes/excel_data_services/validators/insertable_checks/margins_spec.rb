# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Validators::InsertableChecks::Margins do
  let(:tenant) { create(:tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { create(:user, tenant: tenant) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:options) do
    {
      tenant: tenant,
      data: input_data,
      sheet_name: 'Margins',
      options: {
        applicable: tenants_user
      }
    }
  end
  let(:tenant_vehicle) do
    create(:tenant_vehicle,
           tenant: tenant,
           name: 'standard',
           carrier: build(:carrier, name: 'consolidation'))
  end

  before do
    itinerary = create(:itinerary, name: 'Dalian - Gothenburg', tenant: tenant)
    create(:pricings_margin,
           tenant: tenants_tenant,
           applicable: tenants_user,
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
            reason: "There is specified service level does not exist in the database.\nfast - consolidation.",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks}]
        )
      end
    end
  end
end
