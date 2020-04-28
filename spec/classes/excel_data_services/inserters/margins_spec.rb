# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Inserters::Margins do
  before do
    create(:itinerary, tenant: tenant, name: 'Ningbo - Gothenburg')
  end

  let(:tenant) { create(:tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:carrier) { create(:carrier, code: 'consolidation', name: 'Consolidation') }
  let(:applicable) { tenants_tenant }
  let!(:itinerary) { create(:itinerary, tenant: tenant, name: 'Dalian - Gothenburg') }
  let!(:tenant_vehicle) { create(:tenant_vehicle, tenant: tenant, carrier: carrier) }
  let!(:charge_category) { create(:charge_category, :bas, tenant: tenant) }
  let(:options) { { tenant: tenant, data: input_data, options: { applicable: applicable } } }
  let(:input_data) { build(:excel_data_restructured_correct_margins) }

  describe '.insert' do
    context 'with no conflicts' do
      let(:expected_stats) do
        { "pricings/margins": { number_created: 1, number_updated: 0, number_deleted: 0 },
          "pricings/details": { number_created: 2, number_updated: 0, number_deleted: 0 },
          errors: [] }
      end

      it 'returns correct stats and creates correct data' do
        stats = described_class.insert(options)
        expect(stats).to eq(expected_stats)
      end
    end

    context 'with conflicting margins' do
      before do
        FactoryBot.create(:freight_margin,
                          tenant_vehicle: tenant_vehicle,
                          itinerary: itinerary,
                          applicable: tenants_tenant,
                          operator: '%',
                          value: 0,
                          tenant: tenants_tenant,
                          cargo_class: 'lcl',
                          effective_date: Date.parse('Tue, 01 Jan 2019'),
                          expiration_date: Date.parse('25 Mar 2019')).tap do |tapped_margin|
          FactoryBot.create(:pricings_detail,
                            charge_category: charge_category,
                            margin: tapped_margin,
                            operator: '+',
                            value: 0.1)
        end
      end

      let(:expected_stats) do
        { "pricings/margins": { number_created: 1, number_updated: 0, number_deleted: 1 },
          "pricings/details": { number_created: 2, number_updated: 0, number_deleted: 1 },
          errors: [] }
      end

      it 'returns correct stats and creates correct data' do
        stats = described_class.insert(options)
        expect(stats).to eq(expected_stats)
      end
    end
  end
end
