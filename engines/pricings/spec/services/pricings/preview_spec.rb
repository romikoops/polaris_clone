# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pricings::Preview do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let!(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:lcl_pricing) { FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1, itinerary: itinerary) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:args) do
    {
      selectedOriginHub: itinerary.hubs.first.id,
      selectedDestinationHub: itinerary.hubs.last.id,
      selectedCargoClass: 'lcl',
      target_id: user.id,
      target_type: 'user'
    }
  end
  let(:company) do
    FactoryBot.create(:companies_company, :with_member, organization: organization, member: user)
  end
  let(:group) do
    group = FactoryBot.create(:groups_group, organization: organization)
    FactoryBot.create(:groups_membership, group: group, member: user)
    group
  end

  before do
    FactoryBot.create(:organizations_scope, content: {}, target: organization)
    %w[ocean air rail truck trucking local_charge].flat_map do |mot|
      [
        FactoryBot.create(:freight_margin, default_for: mot, organization: organization, applicable: organization, value: 0),
        FactoryBot.create(:trucking_on_margin, default_for: mot, organization: organization, applicable: organization, value: 0),
        FactoryBot.create(:trucking_pre_margin, default_for: mot, organization: organization, applicable: organization, value: 0),
        FactoryBot.create(:import_margin, default_for: mot, organization: organization, applicable: organization, value: 0),
        FactoryBot.create(:export_margin, default_for: mot, organization: organization, applicable: organization, value: 0)
      ]
    end
    FactoryBot.create(:solas_charge, organization: organization)
    FactoryBot.create(:puf_charge, organization: organization)
    FactoryBot.create(:profiles_profile, user_id: user.id)
  end

  describe '.perform' do
    context ' with no trucking' do
      it 'generates the preview for port-to-port with one pricing available' do
        user_margin = FactoryBot.create(:freight_margin, pricing: lcl_pricing, organization: organization, applicable: user)
        results = described_class.new(target: user, organization: organization, params: args).perform
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 0, :source_id)).to eq(user_margin.id)
          expect(results.dig(0, :freight, :fees, :bas, :final, 'rate')).to eq(27.5)
        end
      end

      it 'returns the examples for a group' do
        group_margin = FactoryBot.create(:freight_margin, pricing: lcl_pricing, organization: organization, applicable: group)
        results = described_class.new(target: group, organization: organization, params: args).perform

        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 0, :source_id)).to eq(group_margin.id)
          expect(results.dig(0, :freight, :fees, :bas, :final, 'rate')).to eq(27.5)
        end
      end

      it 'returns the examples for a company' do
        company_margin = FactoryBot.create(:freight_margin, pricing: lcl_pricing, organization: organization, applicable: company)
        results = described_class.new(target: company, organization: organization, params: args).perform

        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 0, :source_id)).to eq(company_margin.id)
          expect(results.dig(0, :freight, :fees, :bas, :final, 'rate')).to eq(27.5)
        end
      end

      it 'returns the examples for a company through the user' do
        company_margin = FactoryBot.create(:freight_margin, pricing: lcl_pricing, organization: organization, applicable: company)
        results = described_class.new(target: user, organization: organization, params: args).perform

        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 0, :source_id)).to eq(company_margin.id)
          expect(results.dig(0, :freight, :fees, :bas, :final, 'rate')).to eq(27.5)
        end
      end

      it 'returns the examples with the steps in correct order' do
        user_margin_1 = FactoryBot.create(:freight_margin, pricing: lcl_pricing, organization: organization, applicable: user, application_order: 0)
        user_margin_2 = FactoryBot.create(:freight_margin, pricing: lcl_pricing, organization: organization, applicable: user, application_order: 2)
        user_margin_3 = FactoryBot.create(:freight_margin, pricing: lcl_pricing, organization: organization, applicable: user, application_order: 3)
        results = described_class.new(target: user, organization: organization, params: args).perform

        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 0, :source_id)).to eq(user_margin_1.id)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 0, :data, 'rate')).to eq(27.5)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 1, :source_id)).to eq(user_margin_2.id)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 1, :data, 'rate')).to eq(30.25)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 2, :source_id)).to eq(user_margin_3.id)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 2, :data, 'rate')).to eq(33.275)
        end
      end
    end

    context ' with trucking' do
      let(:pickup_address) { FactoryBot.create(:gothenburg_address) }
      let(:delivery_address) { FactoryBot.create(:shanghai_address) }
      let(:pickup_location) { FactoryBot.create(:trucking_location, zipcode: pickup_address.zip_code, country_code: 'SE') }
      let(:delivery_location) do
        FactoryBot.create(:trucking_location,
                          country_code: 'CN',
                          location: FactoryBot.create(:locations_location,
                                                      bounds: FactoryBot.build(:legacy_bounds,
                                                                               lat: delivery_address.latitude,
                                                                               lng: delivery_address.longitude)))
      end
      let!(:pickup_trucking) { FactoryBot.create(:trucking_with_wm_rates, organization: organization, location: pickup_location, hub: origin_hub) }
      let!(:delivery_trucking) { FactoryBot.create(:trucking_with_cbm_kg_rates, organization: organization, location: delivery_location, hub: destination_hub, carriage: 'on') }
      let!(:origin_local_charges) { FactoryBot.create(:legacy_local_charge, tenant_vehicle: tenant_vehicle_1, organization: organization, hub: origin_hub) }
      let!(:destination_local_charges) { FactoryBot.create(:legacy_local_charge, tenant_vehicle: tenant_vehicle_1, organization: organization, hub: destination_hub, direction: 'import') }

      let(:trucking_args) do
        {
          selectedCargoClass: 'lcl',
          target_id: user.id,
          target_type: 'user',
          selectedOriginTrucking: {
            lat: pickup_address.latitude,
            lng: pickup_address.longitude
          },
          selectedDestinationTrucking: {
            lat: delivery_address.latitude,
            lng: delivery_address.longitude
          }
        }
      end
      let!(:freight_margin) { FactoryBot.create(:freight_margin, pricing: lcl_pricing, organization: organization, applicable: user) }
      let!(:export_margin) { FactoryBot.create(:export_margin, origin_hub: origin_hub, organization: organization, applicable: user) }
      let!(:import_margin) { FactoryBot.create(:import_margin, destination_hub: destination_hub, organization: organization, applicable: user) }
      let!(:trucking_pre_margin) { FactoryBot.create(:trucking_pre_margin, destination_hub: origin_hub, organization: organization, applicable: user) }
      let!(:trucking_on_margin) { FactoryBot.create(:trucking_on_margin, origin_hub: destination_hub, organization: organization, applicable: user) }
      let(:zipcode_pre_availability) { FactoryBot.create(:trucking_type_availability, query_method: :zipcode, carriage: 'pre', load_type: 'cargo_item') }
      let(:location_on_availability) { FactoryBot.create(:trucking_type_availability, query_method: :location, carriage: 'on', load_type: 'cargo_item') }

      before do
        FactoryBot.create(:trucking_hub_availability, hub: origin_hub, type_availability: zipcode_pre_availability)
        FactoryBot.create(:trucking_hub_availability, hub: destination_hub, type_availability: location_on_availability)
        Geocoder::Lookup::Test.add_stub([pickup_address.latitude, pickup_address.longitude], [
                                          'address_components' => [{ 'types' => ['premise'] }],
                                          'address' => 'Göteborg, Sweden',
                                          'city' => pickup_address.city,
                                          'country' => pickup_address.country.name,
                                          'country_code' => pickup_address.country.code,
                                          'postal_code' => pickup_address.zip_code
                                        ])
        Geocoder::Lookup::Test.add_stub([delivery_address.latitude, delivery_address.longitude], [
                                          'address_components' => [{ 'types' => ['premise'] }],
                                          'address' => 'Shanghai, China',
                                          'city' => delivery_address.city,
                                          'country' => delivery_address.country.name,
                                          'country_code' => delivery_address.country.code,
                                          'postal_code' => delivery_address.zip_code
                                        ])
      end

      it 'generates the preview for port-to-port with one pricing available' do
        results = described_class.new(target: user, organization: organization, params: trucking_args).perform

        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.dig(0, :freight, :fees, :bas, :margins, 0, :source_id)).to eq(freight_margin.id)
          expect(results.dig(0, :freight, :fees, :bas, :final, 'rate')).to eq(27.5)
          expect(results.dig(0, :import, :fees, :solas, :margins, 0, :source_id)).to eq(import_margin.id)
          expect(results.dig(0, :import, :fees, :solas, :final, 'value')).to eq(19.25)
          expect(results.dig(0, :export, :fees, :solas, :margins, 0, :source_id)).to eq(export_margin.id)
          expect(results.dig(0, :export, :fees, :solas, :final, 'value')).to eq(19.25)
          expect(results.dig(0, :trucking_pre, :fees, :puf, :margins, 0, :source_id)).to eq(trucking_pre_margin.id)
          expect(results.dig(0, :trucking_pre, :fees, :puf, :final, 'value')).to eq(275)
          expect(results.dig(0, :trucking_pre, :fees, :trucking_lcl, :margins, 0, :source_id)).to eq(trucking_pre_margin.id)
          expect(results.dig(0, :trucking_pre, :fees, :trucking_lcl, :final, 'wm', 0, 'rate', 'value')).to eq(110)
          expect(results.dig(0, :trucking_on, :fees, :puf, :margins, 0, :source_id)).to eq(trucking_on_margin.id)
          expect(results.dig(0, :trucking_on, :fees, :puf, :final, 'value')).to eq(275)
          expect(results.dig(0, :trucking_on, :fees, :trucking_lcl, :margins, 0, :source_id)).to eq(trucking_on_margin.id)
          expect(results.dig(0, :trucking_on, :fees, :trucking_lcl, :final, 'cbm', 0, 'rate', 'value')).to eq(261.25)
        end
      end
    end

    context 'with dedicated_pricings_only' do
      before do
        organization.scope.update(content: { dedicated_pricings_only: true })
      end

      context 'without valid rates' do
        it 'returns an empty array when there are no group specific pricings' do
          results = described_class.new(target: user, organization: organization, params: args).perform
          expect(results).to be_empty
        end
      end

      context 'with valid rates' do
        let(:group_lcl_pricing) do
          FactoryBot.create(:lcl_pricing,
                            tenant_vehicle: tenant_vehicle_1,
                            itinerary: itinerary,
                            group_id: group.id,
                            fee_attrs: {
                              rate: 1000,
                              rate_basis: :per_container_rate_basis,
                              min: nil,
                              charge_category: FactoryBot.create(:baf_charge)
                            })
        end
        let!(:user_margin) { FactoryBot.create(:freight_margin, pricing: group_lcl_pricing, organization: organization, applicable: user) }

        it 'returns an empty array when there are no group specific pricings' do
          results = described_class.new(target: user, organization: organization, params: args).perform
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results.dig(0, :freight, :fees, :bas, :margins, 0, :source_id)).to eq(user_margin.id)
            expect(results.dig(0, :freight, :fees, :bas, :final, 'rate')).to eq(27.5)
            expect(results.dig(0, :freight, :fees, :baf, :margins, 0, :source_id)).to eq(user_margin.id)
            expect(results.dig(0, :freight, :fees, :baf, :final, 'rate')).to eq(1100)
          end
        end
      end
    end
  end
end
