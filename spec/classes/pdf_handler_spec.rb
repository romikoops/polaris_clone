# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PdfHandler do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let!(:shipment) { create(:shipment, tenant: tenant, user: user, load_type: 'cargo_item') }
  let!(:agg_shipment) { create(:shipment, tenant: tenant, user: user, load_type: 'cargo_item', with_aggregated_cargo: true) }
  let(:default_args) do
    {
      shipment: shipment,
      cargo_units: shipment.cargo_units
    }
  end
  let(:klass) { described_class.new(default_args) }

  before(:each) do
    dummy_selected_offer = build(:multi_currency_selected_offer, trip_id: shipment.trip_id)
    consolidated_selected_offer = build(:consolidated_selected_offer, trip_id: shipment.trip_id)
    allow(shipment).to receive(:selected_offer).and_return(dummy_selected_offer)
    allow(agg_shipment).to receive(:selected_offer).and_return(consolidated_selected_offer)
  end

  context 'FCL 20 shipment' do
    let!(:fcl_shipment) { create(:shipment, tenant: tenant, user: user, load_type: 'container') }
    let(:default_args) do
      {
        shipment: fcl_shipment,
        cargo_units: fcl_shipment.cargo_units
      }
    end
    let(:klass) { described_class.new(default_args) }

    describe 'hide_grand_total' do
      before do
        dummy_selected_offer = build(:single_currency_selected_offer, trip_id: fcl_shipment.trip_id)
        allow(fcl_shipment).to receive(:selected_offer).and_return(dummy_selected_offer)
      end

      let!(:scope) do
        create(:tenants_scope, target: tenants_tenant, content: {
                 hide_converted_grand_total: true
               })
      end

      it 'will not hide the grand total with a single currency' do
        expect(klass.hide_grand_total?(fcl_shipment)).to eq(false)
      end
    end
  end

  context 'LCL shipment' do
    describe 'hide_grand_total' do
      let!(:scope) do
        create(:tenants_scope, target: tenants_tenant, content: {
                 hide_converted_grand_total: true
               })
      end

      it 'will hide the grand total with a multiple currencies and scope.hide_converted_grand_total' do
        expect(klass.hide_grand_total?(shipment)).to eq(true)
      end

      it 'will hide the grand total with a consolidated selected offer structure' do
        expect(klass.hide_grand_total?(agg_shipment)).to eq(false)
      end
    end
  end

  context 'helper methods' do
    let!(:scope) do
      create(:tenants_scope, target: tenants_tenant, content: {
               hide_converted_grand_total: true,
               fine_fee_detail: true,
               chargeable_weight_view: 'weight'
             })
    end

    describe '.determine_render_string' do
      it 'returns the key and name' do
        scope.update(content: scope.content.merge(fee_detail: 'key_and_name'))
        expect(klass.determine_render_string(key: 'BAS', name: 'Basic Ocean Freight')).to eq('BAS - Basic Ocean Freight')
      end

      it 'returns the key' do
        scope.update(content: scope.content.merge(fee_detail: 'key'))
        expect(klass.determine_render_string(key: 'BAS', name: 'Basic Ocean Freight')).to eq('BAS')
      end

      it 'returns the name' do
        scope.update(content: scope.content.merge(fee_detail: 'name'))
        expect(klass.determine_render_string(key: 'BAS', name: 'Basic Ocean Freight')).to eq('Basic Ocean Freight')
      end
    end

    describe '.extract_key' do
      it 'returns MOT Freight as key' do
        result = klass.extract_key(section_key: 'cargo', key: 'unknown_bas', mot: 'ocean')
        expect(result).to eq('Ocean Freight')
      end

      it 'returns the key without the _included' do
        result = klass.extract_key(section_key: 'cargo', key: 'included_bas', mot: 'ocean')
        expect(result).to eq('BAS')
      end

      it 'returns the key stripped of underscores and upcased' do
        result = klass.extract_key(section_key: 'cargo', key: 'piracy_surcharge', mot: 'ocean')
        expect(result).to eq('PIRACY SURCHARGE')
      end
    end

    describe '.extract_name' do
      it 'returns Consolidated Freight Rate as the name' do
        scope.update(content: scope.content.merge(consolidated_cargo: true))
        result = klass.extract_name(section_key: 'cargo', name: 'Basic Ocean Freight', mot: 'ocean')
        expect(result).to eq('Consolidated Freight Rate')
      end

      it 'returns Ocean Freight Rate as the name' do
        scope.update(content: scope.content.merge(fine_fee_detail: false))
        result = klass.extract_name(section_key: 'cargo', name: 'Basic Ocean Freight', mot: 'ocean')
        expect(result).to eq('Ocean Freight Rate')
      end

      it 'returns the key stripped of underscores and upcased' do
        scope.update(content: scope.content.merge(fine_fee_detail: true, consolidated_cargo: false))
        result = klass.extract_name(section_key: 'cargo', name: 'Basic Ocean Freight', mot: 'ocean')
        expect(result).to eq('Basic Ocean Freight')
      end
    end

    describe '.calculate_cargo_data' do
      it 'returns a hash displaying chargeable weight in kg' do
        result = klass.calculate_cargo_data(shipment)
        expect(result).to eq(200)
      end

      it 'returns a hash displaying chargeable weight in volume' do
        scope.update(content: scope.content.merge(chargeable_weight_view: 'volume'))
        result = klass.calculate_cargo_data(shipment)
        expect(result).to eq(200)
      end

      it 'returns a hash displaying chargeable weight in kg (dynamic)' do
        scope.update(content: scope.content.merge(chargeable_weight_view: 'dynamic'))
        result = klass.calculate_cargo_data(shipment)
        expect(result).to eq(200)
      end

      it 'returns a hash displaying chargeable weight in vol (dynamic)' do
        scope.update(content: scope.content.merge(chargeable_weight_view: 'dynamic'))
        result = klass.calculate_cargo_data(agg_shipment)
        expect(result).to eq(200)
      end

      it 'returns a hash displaying chargeable weight in kg and vol' do
        scope.update(content: scope.content.merge(chargeable_weight_view: 'both'))
        result = klass.calculate_cargo_data(shipment)
        expect(result).to eq(200)
      end

      it 'returns a hash displaying chargeable weight in kg with no chargeable_weight_view value' do
        scope.update(content: scope.content.merge(chargeable_weight_view: ''))
        result = klass.calculate_cargo_data(agg_shipment)
        expect(result).to eq(200)
      end
    end
  end
end
