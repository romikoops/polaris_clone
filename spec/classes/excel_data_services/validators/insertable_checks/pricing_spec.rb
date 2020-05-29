# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Validators::InsertableChecks::Pricing do
  let(:tenant) { create(:tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:options) { { tenant: tenant, sheet_name: 'Sheet1', data: input_data } }
  let!(:pricings) do
    [
      create(
        :lcl_pricing,
        tenant: tenant,
        effective_date: Date.parse('Thu, 15 Mar 2018').beginning_of_day,
        expiration_date: Date.parse('Sun, 17 Mar 2019').end_of_day.change(usec: 0),
        itinerary: itineraries.first,
        tenant_vehicle: tenant_vehicle
      )
    ]
  end
  let(:itineraries) do
    [
      create(:gothenburg_shanghai_itinerary, tenant: tenant)
    ]
  end

  let(:vehicle) do
    create(:vehicle,
           tenant_vehicles: [tenant_vehicle])
  end
  let(:tenant_vehicle) { create(:tenant_vehicle, tenant: tenant) }

  context 'with faulty data' do
    let(:group_a) { build_stubbed(:tenants_group, tenant: tenants_tenant, name: 'GROUP A', id: '000-gr0up-a-id-123') }
    let(:group_b) { build_stubbed(:tenants_group, tenant: tenants_tenant, name: 'GROUP B', id: '000-gr0up-b-id-456') }

    before do
      allow(Tenants::Group).to receive(:find_by).with(tenant: tenants_tenant, id: 'other-000-gr0up-a-id-123')
      allow(Tenants::Group).to receive(:find_by).with(tenant: tenants_tenant, name: 'OTHER GROUP B')
      allow(Tenants::Group).to receive(:find_by).with(tenant: tenants_tenant, id: '000-gr0up-a-id-123').and_return(group_a)
      allow(Tenants::Group).to receive(:find_by).with(tenant: tenants_tenant, name: 'GROUP B').and_return(group_b)
    end

    let(:input_data) { build(:excel_data_restructured_faulty_pricings_one_fee_col_and_ranges) }

    describe '.validate' do
      let(:expected_results) do
        [{ type: :error, row_nr: 2,
           sheet_name: 'Sheet1',
           reason: 'Effective date must lie before before expiration date!',
           exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks },
        { type: :error,
          row_nr: 2,
          sheet_name: 'Sheet1',
          reason: 'Hub "GothenERRORburg, Sweden" (Ocean) not found!',
          exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks },
        { type: :error,
          row_nr: 3,
          sheet_name: 'Sheet1',
          reason: "The Group with ID 'other-000-gr0up-a-id-123' does not exist!",
          exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks },
        { type: :error,
          row_nr: 3,
          sheet_name: 'Sheet1',
          reason: 'A user with email "Non.Existent@email.address" does not exist.',
          exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks },
        { type: :warning,
          row_nr: 3,
          sheet_name: 'Sheet1',
          reason: "There exist rates (in the system or this file) with an overlapping effective period.\n(Old is covered by new: [2018-03-15 00:00 - 2019-03-17 23:59] <-> [2018-03-15 00:00 - 2019-03-17 23:59]).",
          exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks },
        { type: :error,
          row_nr: 3,
          sheet_name: 'Sheet1',
          reason: "The Group with name 'OTHER GROUP B' does not exist!",
          exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks },
        { type: :error,
          row_nr: 3,
          sheet_name: 'Sheet1',
          reason: "The Group with ID '000-gr0up-a-id-123' is not the same as the group with name 'GROUP B'!",
          exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks },
        { type: :error,
          row_nr: 3,
          sheet_name: 'Sheet1',
          reason: "\"W/M\" is not a valid Rate Basis.",
          exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks }]
      end

      it 'logs the errors' do
        validator = described_class.new(options)
        validator.perform
        expect(validator.results).to match_array(expected_results)
      end
    end
  end
end
