# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MaxDimensionsController, type: :controller do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:response_data) { JSON.parse(response.body).dig('data') }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary) }
  let(:carrier) { FactoryBot.create(:legacy_carrier, code: 'msc') }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier: carrier, organization: organization) }
  let!(:max_dimensions) { FactoryBot.create_list(:legacy_max_dimensions_bundle, 1, organization: organization) }
  let!(:max_agg_dimensions) {
    FactoryBot.create_list(:legacy_max_dimensions_bundle, 1, organization: organization, aggregate: true)
  }

  let(:default_max_dimensions) do
    # Not good. {H.Ezekiel}
    dimensions = Legacy::MaxDimensionsBundle.where(id: max_dimensions.pluck(:id)).to_max_dimensions_hash
    dimensions.deep_transform_keys! { |key| key.to_s.camelize(:lower) }.as_json
  end
  let(:default_max_agg_dimensions) do
    agg_dimensions = Legacy::MaxDimensionsBundle.where(id: max_agg_dimensions.pluck(:id)).to_max_dimensions_hash
    agg_dimensions.deep_transform_keys! { |key| key.to_s.camelize(:lower) }.as_json
  end

  before do
    allow(controller).to receive(:current_organization).and_return(organization)
  end

  describe 'GET #index' do
    context 'without carrier mdbs' do
      it 'returns the default max dimensions' do
        get :index, params: { organization_id: organization.id }
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(response_data['maxDimensions']).to eq(default_max_dimensions)
          expect(response_data['maxAggregateDimensions']).to eq(default_max_agg_dimensions)
        end
      end
    end

    context 'without carrier mdbs but itinerary ids and service provided' do
      let(:params) {
        {
          organization_id: organization.id,
          itinerary_ids: [itinerary.id].join(','),
          tenant_vehicle: tenant_vehicle
        }
      }

      it 'returns the default max dimensions' do
        get :index, params: params
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(response_data['maxDimensions']).to eq(default_max_dimensions)
          expect(response_data['maxAggregateDimensions']).to eq(default_max_agg_dimensions)
        end
      end
    end

    context 'without unit limits but filters provided' do
      let!(:max_dimensions) { nil }
      let(:params) {
        {
          organization_id: organization.id,
          itinerary_ids: [itinerary.id].join(','),
          tenant_vehicle: tenant_vehicle
        }
      }

      it 'returns the default max dimensions' do
        get :index, params: params
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(response_data['maxDimensions']).to eq({})
          expect(response_data['maxAggregateDimensions']).to eq(default_max_agg_dimensions)
        end
      end
    end

    context 'with carrier mdbs' do
      before do
        FactoryBot.create(:lcl_pricing,
          organization: organization,
          tenant_vehicle: tenant_vehicle,
          itinerary: itinerary)
      end

      let!(:carrier_mdb) {
        FactoryBot.create(:legacy_max_dimensions_bundle,
          organization: organization,
          carrier: carrier,
          width: 100,
          mode_of_transport: 'ocean')
      }

      it 'returns the default max dimensions' do
        get :index, params: { organization_id: organization.id, itinerary_ids: [itinerary.id].join(',') }

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(response_data.dig('maxDimensions', 'ocean', 'width')).to eq(carrier_mdb.width.to_s)
        end
      end
    end

    context 'with tenant_vehicle mdbs' do
      before do
        FactoryBot.create(:lcl_pricing,
          organization: organization,
          tenant_vehicle: tenant_vehicle,
          itinerary: itinerary)
      end

      let!(:tenant_vehicle_mdb) {
        FactoryBot.create(:legacy_max_dimensions_bundle,
          organization: organization,
          tenant_vehicle: tenant_vehicle,
          width: 100,
          mode_of_transport: 'ocean')
      }

      it 'returns the default max dimensions' do
        get :index, params: { organization_id: organization.id, itinerary_ids: [itinerary.id].join(',') }

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(response_data.dig('maxDimensions', 'ocean', 'width')).to eq(tenant_vehicle_mdb.width.to_s)
        end
      end
    end
  end
end
