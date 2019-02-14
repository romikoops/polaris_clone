# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::DataValidator::Insertability::Pricing do
  let(:klass_identifier) { 'Pricing' }
  let(:tenant) { create(:tenant) }
  let(:options) { { tenant: tenant, data: input_data, klass_identifier: klass_identifier } }
  let!(:pricings) do
    [
      create(
        :pricing,
        tenant: tenant,
        effective_date: Date.parse('Thu, 15 Mar 2018'),
        expiration_date: Date.parse('Sun, 17 Mar 2019'),
        transport_category: cargo_transport_category,
        itinerary: itineraries.first,
        tenant_vehicle: tenant_vehicle,
        uuid: 'ae973d1d-89d5-4213-a0cd-e25724e9c60a'
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
    [create(:hub, tenant: tenant, name: 'Gothenburg Port', hub_type: 'ocean'),
     create(:hub, tenant: tenant, name: 'Shanghai Port', hub_type: 'ocean')]
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
    let(:input_data) { build(:excel_data_restructured_faulty_pricings) }

    describe '.validate' do
      it 'logs the errors' do
        expect(described_class.validate(options)).to eq(
          [
            { reason: 'Overlapping effective period. (UUID: 12345-abcde-DIFFERENT!!)', row_nr: 2 }
          ]
        )
      end
    end
  end
end
