# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::QuotationsController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers['Authorization'] = token_header
      { USD: 1.26, SEK: 8.26 }.each do |currency, rate|
        FactoryBot.create(:legacy_exchange_rate, from: currency, to: "EUR", rate: rate)
      end
      FactoryBot.create(:organizations_theme, organization: organization)
    end

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user) { FactoryBot.create(:organizations_user, :with_profile, organization_id: organization.id) }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
    let(:token_header) { "Bearer #{access_token.token}" }

    describe 'POST #create' do
      let(:origin_nexus) { FactoryBot.create(:legacy_nexus, organization: organization) }
      let(:destination_nexus) { FactoryBot.create(:legacy_nexus, organization: organization) }
      let(:origin_hub) { itinerary.origin_hub }
      let(:destination_hub) { itinerary.destination_hub }
      let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly') }
      let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: 'quickly') }
      let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization_id: organization.id) }
      let(:trip_1) { FactoryBot.create(:trip_with_layovers, itinerary: itinerary, load_type: 'container', tenant_vehicle: tenant_vehicle) }
      let(:trip_2) { FactoryBot.create(:trip_with_layovers, itinerary: itinerary, load_type: 'container', tenant_vehicle: tenant_vehicle_2) }
      let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
      let(:token_header) { "Bearer #{access_token.token}" }
      let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
      let(:trips) do
        [tenant_vehicle, tenant_vehicle_2].flat_map do |tv|
          [
            FactoryBot.create(:trip_with_layovers, itinerary: itinerary, load_type: 'container', tenant_vehicle: tv),
            FactoryBot.create(:trip_with_layovers, itinerary: itinerary, load_type: 'cargo_item', tenant_vehicle: tv)
          ]
        end
      end
      let(:cargo_items_attributes) { [] }
      let(:containers_attributes) { [] }
      let(:load_type) { 'container' }
      let(:params) do
        {
          organization_id: organization.id,
          quote: {
            selected_date: Time.zone.now,
            organization_id: organization.id,
            user_id: user.id,
            load_type: load_type,
            origin: { nexus_id: origin_hub.nexus_id },
            destination: { nexus_id: destination_hub.nexus_id }
          },
          shipment_info: {
            trucking_info: { pre_carriage: :pre },
            cargo_items_attributes: cargo_items_attributes,
            containers_attributes: containers_attributes
          }
        }
      end

      context 'with available tenders' do
        before do
          [tenant_vehicle, tenant_vehicle_2].each do |t_vehicle|
            FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, tenant_vehicle: t_vehicle, organization: organization)
            FactoryBot.create(:lcl_pricing, itinerary: itinerary, tenant_vehicle: t_vehicle, organization: organization)
          end
          OfferCalculator::Schedule.from_trips(trips)
          FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle, organization: organization)
          FactoryBot.create(:freight_margin, default_for: 'ocean', organization_id: organization.id, applicable: organization, value: 0)
        end

        context 'when client is provided' do
          it 'returns results successfully' do
            post :create, params: params

            expect(response).to be_successful
          end

          it 'returns 2 available tenders' do
            post :create, params: params

            expect(response_data.count).to eq 2
          end
        end

        context 'when no client is provided' do
          before do
            params[:quote][:user_id] = nil
            FactoryBot.create(:groups_group, organization: organization, name: 'default')
            FactoryBot.create(:organizations_scope, target: organization, content: { default_currency: 'usd' })
          end

          it 'returns prices with default margins' do
            post :create, params: params

            expect(response_data.count).to eq 2
          end
        end

        context 'when cargo items are invalid' do
          let(:load_type) { 'cargo_item' }
          let(:cargo_items_attributes) do
            [
              {
                'id' => SecureRandom.uuid,
                'payload_in_kg' => 120,
                'total_volume' => 0,
                'total_weight' => 0,
                'width' => 0,
                'length' => 80,
                'height' => 1200,
                'quantity' => 1,
                'cargo_item_type_id' => pallet.id,
                'dangerous_goods' => false,
                'stackable' => true
              }
            ]
          end

          it 'returns validations errors' do
            post :create, params: params
            aggregate_failures do
              expect(response.code).to eq '417'
              expect(response_data.count).to eq 2
            end
          end
        end

        context 'when containers are invalid' do
          let(:containers_attributes) do
            [
              {
                'id' => SecureRandom.uuid,
                'payload_in_kg' => 999_999,
                'size_class' => 'fcl_20',
                'total_weight' => 0,
                'width' => 0,
                'length' => 0,
                'height' => 0,
                'quantity' => 1
              }
            ]
          end

          before do
            FactoryBot.create(:legacy_max_dimensions_bundle,
                              organization: organization,
                              mode_of_transport: 'ocean',
                              payload_in_kg: 10_000,
                              cargo_class: 'fcl_20')
          end

          it 'returns validation errors' do
            post :create, params: params
            aggregate_failures do
              expect(response.code).to eq '417'
              expect(response_data.count).to eq 1
            end
          end
        end

        context 'when cargo items are valid' do
          let(:load_type) { 'cargo_item' }
          let(:cargo_items_attributes) do
            [
              {
                'id' => SecureRandom.uuid,
                'payload_in_kg' => 120,
                'total_volume' => 0,
                'total_weight' => 0,
                'width' => 120,
                'length' => 80,
                'height' => 120,
                'quantity' => 1,
                'cargo_item_type_id' => pallet.id,
                'dangerous_goods' => false,
                'stackable' => true
              }
            ]
          end

          it 'returns prices with default margins' do
            post :create, params: params
            aggregate_failures do
              expect(response.code).to eq '200'
              expect(response_data.count).to eq 2
            end
          end
        end
      end

      context 'when no available schedules' do
        it 'returns no available schedules error' do
          post :create, params: params

          expect(response_error).to eq 'There are no departures for this timeframe.'
        end
      end
    end

    describe 'GET #show' do
      before do
        FactoryBot.create(:legacy_shipment, with_breakdown: true, with_tenders: true, organization_id: organization.id, user: user)
      end

      context 'when origin and destinations are nexuses' do
        let(:quotation) { Quotations::Quotation.last }

        it 'renders origin and destination as nexus objects' do
          get :show, params: { organization_id: organization.id, id: quotation.id }

          aggregate_failures do
            expect(response_data.dig('attributes', 'origin', 'data', 'id').to_i).to eq quotation.origin_nexus_id
            expect(response_data.dig('attributes', 'destination', 'data', 'id').to_i).to eq quotation.destination_nexus_id
          end
        end
      end

      context 'when origin and destination are addresses' do
        let(:address) { FactoryBot.create(:legacy_address) }
        let(:quotation) do
          quotation = Quotations::Quotation.last
          quotation.update!(pickup_address: address,
                            delivery_address: address)
          quotation
        end

        it 'renders origin and destination as address objects' do
          get :show, params: { organization_id: organization.id, id: quotation.id }

          aggregate_failures do
            expect(response_data.dig('attributes', 'origin', 'data', 'id').to_i).to eq quotation.pickup_address_id
            expect(response_data.dig('attributes', 'destination', 'data', 'id').to_i).to eq quotation.delivery_address_id
          end
        end
      end

      context 'when cargo is lcl' do
        let(:quotation) { Quotations::Quotation.last }
        let!(:cargo_item) { FactoryBot.create(:legacy_cargo_item, shipment: Legacy::Shipment.last) }

        it 'returns the cargo items' do
          get :show, params: { organization_id: organization.id, id: quotation.id }

          expect(response_data.dig('attributes', 'cargoItems', 'data', 0, 'id').to_i).to eq cargo_item.id
        end
      end
    end

    describe 'GET #index' do
      context "when quotations exist" do
        before do
          FactoryBot.create_list(:legacy_shipment, 5, with_breakdown: true, with_tenders: true,
                                                      organization_id: organization.id, user: user)
        end

        it 'renders a list of quotations' do
          get :index, params: { organization_id: organization.id }

          aggregate_failures do
            expect(response_data.count).to eq 5
          end
        end

        it 'paginates results' do
          get :index, params: { organization_id: organization.id, per_page: 2 }

          aggregate_failures do
            expect(response_data.map { |q| q['id'] }).to eq Quotations::Quotation.limit(2).ids
          end
        end
      end

      context "when quotations do not exist" do
        it 'renders an empty list' do
          get :index, params: { organization_id: organization.id }

          aggregate_failures do
            expect(response_data).to eq []
          end
        end
      end
    end

    describe 'POST #download' do
      before do
        FactoryBot.create(:legacy_shipment, with_breakdown: true, with_tenders: true, organization_id: organization.id, user: user)
      end

      shared_examples_for "a downloadable quotation format" do |format|
        context 'without tender ids' do
          let(:quotation) { Quotations::Quotation.last }

          it 'returns the url of the generated document for the quotation tenders' do
            post :download, params: { organization_id: organization.id, quotation_id: quotation.id, format: format }

            aggregate_failures do
              expect(response_data.dig('attributes', 'url')).to include('test.host')
            end
          end
        end

        context 'with tender ids' do
          let(:quotation) { Quotations::Quotation.last }

          it 'returns the url of the generated document for the specified tenders' do
            post :download, params: {
              organization_id: organization.id,
              format: format,
              quotation_id: quotation.id,
              tender_ids: quotation.tenders.ids
            }

            aggregate_failures do
              expect(response_data.dig('attributes', 'url')).to include('test.host')
            end
          end
        end

        context 'with legacy tender ids' do
          let(:quotation) { Quotations::Quotation.last }

          it 'renders origin and destination as nexus objects' do
            post :download, params: {
              organization_id: organization.id,
              quotation_id: quotation.id,
              format: format,
              tenders: [{id: quotation.tenders.first.id }]
            }

            aggregate_failures do
              expect(response_data.dig('attributes', 'url')).to include('test.host')
            end
          end
        end
      end

      context 'when downloading as pdf' do
        it_should_behave_like "a downloadable quotation format", "pdf"
      end

      context 'when downloading as xlsx' do
        it_should_behave_like "a downloadable quotation format", "xlsx"
      end

      context "when format is not specified" do
        let(:quotation) { Quotations::Quotation.last }

        it "is unsuccessful" do
          post :download, params: { organization_id: organization.id, quotation_id: quotation.id, tenders: []}
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body).dig('error')).to eq('Download format is missing or invalid')
        end
      end
    end
  end
end
