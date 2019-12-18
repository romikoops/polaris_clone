# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Validators::InsertableChecks::Pricing do
  let(:tenant) { create(:tenant) }
  let(:options) { { tenant: tenant, data: input_data } }
  let!(:pricings) do
    [
      create(
        :pricing,
        tenant: tenant,
        effective_date: Date.parse('Thu, 15 Mar 2018').beginning_of_day,
        expiration_date: Date.parse('Sun, 17 Mar 2019').end_of_day.change(usec: 0),
        transport_category: cargo_transport_category,
        itinerary: itineraries.first,
        tenant_vehicle: tenant_vehicle
      )
    ]
  end
  let(:itineraries) do
    [
      create(
        :itinerary,
        tenant: tenant,
        name: 'Gothenburg - Shanghai',
        hubs: hubs
      )
    ]
  end
  let(:hubs) do
    [
      create(:hub, tenant: tenant, name: 'Gothenburg Port', hub_type: 'ocean', nexus: nexuses.first),
      create(:hub, tenant: tenant, name: 'Shanghai Port', hub_type: 'ocean', nexus: nexuses.second)
    ]
  end
  let(:nexuses) do
    [
      create(:nexus, tenant: tenant, name: 'Gothenburg'),
      create(:nexus, tenant: tenant, name: 'Shanghai')
    ]
  end
  let(:cargo_transport_category) do
    create(:transport_category, cargo_class: 'lcl', load_type: 'cargo_item')
  end
  let(:vehicle) do
    create(:vehicle,
           transport_categories: [
             cargo_transport_category
           ],
           tenant_vehicles: [tenant_vehicle])
  end
  let(:tenant_vehicle) { create(:tenant_vehicle, tenant: tenant) }

  context 'with faulty data' do
    let(:input_data) { build(:excel_data_restructured_faulty_pricings_one_fee_col_and_ranges) }

    describe '.validate' do
      it 'logs the errors' do
        validator = described_class.new(options)
        validator.perform

        expect(validator.errors).to eq(
          [{ exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
             reason: 'Effective date must lie before before expiration date!',
             row_nr: 2,
             type: :error },
           { exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
             reason: 'Hub "GothenERRORburg" (Ocean) not found!',
             row_nr: 2,
             type: :error },
           { exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
             reason: 'A user with email "Non.Existent@email.address" does not exist.',
             row_nr: 3,
             type: :error },
           { exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
             reason: "There exist rates (in the system or this file) with an overlapping effective period.\n(Old is covered by new: [2018-03-15 00:00 - 2019-03-17 23:59] <-> [2018-03-15 00:00 - 2019-03-17 23:59]).",
             row_nr: 3,
             type: :warning }]
        )
      end
    end
  end
end
