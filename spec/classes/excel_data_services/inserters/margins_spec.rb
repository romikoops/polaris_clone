# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Inserters::Margins do
  before do
    create(:itinerary, organization: organization, name: 'Ningbo - Gothenburg')
  end

  let(:organization) { create(:organizations_organization) }
  let(:carrier) { create(:carrier, code: 'consolidation', name: 'Consolidation') }
  let(:applicable) { organization }
  let!(:itinerary) { create(:itinerary, organization: organization, name: 'Dalian - Gothenburg') }
  let!(:tenant_vehicle) { create(:tenant_vehicle, organization: organization, carrier: carrier) }
  let!(:charge_category) { create(:charge_category, :bas, organization: organization) }
  let(:options) { { organization: organization, data: input_data, options: { applicable: applicable } } }
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
                          applicable: organization,
                          operator: '%',
                          value: 0,
                          organization: organization,
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
