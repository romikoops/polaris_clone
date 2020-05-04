# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MaxDimensionsController, type: :controller do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:response_data) { JSON.parse(response.body).dig('data') }
  let(:default_max_dimensions) { tenant.max_dimensions.deep_transform_keys! { |key| key.to_s.camelize(:lower) }.as_json }
  let(:default_max_agg_dimensions) { tenant.max_aggregate_dimensions.deep_transform_keys! { |key| key.to_s.camelize(:lower) }.as_json }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary) }
  let(:carrier) { FactoryBot.create(:legacy_carrier, code: 'msc') }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier: carrier, tenant: tenant) }

  before do
    allow(controller).to receive(:current_tenant).and_return(tenant)
  end

  describe 'GET #index' do
    context 'without carrier mdbs' do
      it 'returns the default max dimensions' do
        get :index, params: { tenant_id: tenant.id }
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(response_data['maxDimensions']).to eq(default_max_dimensions)
          expect(response_data['maxAggregateDimensions']).to eq(default_max_agg_dimensions)
        end
      end
    end

    context 'with carrier mdbs' do
      before do
        FactoryBot.create(:lcl_pricing, tenant: tenant, tenant_vehicle: tenant_vehicle, itinerary: itinerary)
      end

      let!(:carrier_mdb) { FactoryBot.create(:legacy_max_dimensions_bundle, tenant: tenant, carrier: carrier, dimension_x: 100, mode_of_transport: 'ocean') }

      it 'returns the default max dimensions' do
        get :index, params: { tenant_id: tenant.id, itinerary_ids: [itinerary.id].join(',') }

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(response_data.dig('maxDimensions', 'ocean', 'dimensionX')).to eq(carrier_mdb.dimension_x.to_s)
        end
      end
    end

    context 'with tenant_vehicle mdbs' do
      before do
        FactoryBot.create(:lcl_pricing, tenant: tenant, tenant_vehicle: tenant_vehicle, itinerary: itinerary)
      end

      let!(:tenant_vehicle_mdb) { FactoryBot.create(:legacy_max_dimensions_bundle, tenant: tenant, tenant_vehicle: tenant_vehicle, dimension_x: 100, mode_of_transport: 'ocean') }

      it 'returns the default max dimensions' do
        get :index, params: { tenant_id: tenant.id, itinerary_ids: [itinerary.id].join(',') }

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(response_data.dig('maxDimensions', 'ocean', 'dimensionX')).to eq(tenant_vehicle_mdb.dimension_x.to_s)
        end
      end
    end
  end
end
