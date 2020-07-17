# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pdf::Handler do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let!(:shipment) {
    FactoryBot.create(:completed_legacy_shipment,
      organization: organization,
      user: user,
      load_type: 'cargo_item',
      with_breakdown: true,
      with_tenders: true
    )
  }
  let!(:agg_shipment) { FactoryBot.create(:legacy_shipment, organization: organization, user: user, load_type: 'cargo_item', with_aggregated_cargo: true) }
  let(:pdf_service) { Pdf::Service.new(organization: organization, user: user) }
  let(:default_args) do
    {
      shipment: shipment,
      organization: organization,
      cargo_units: shipment.cargo_units,
      quotes: pdf_service.quotes_with_trip_id(quotation: nil, shipments: [shipment])
    }
  end
  let(:klass) { described_class.new(default_args) }

  before do
    ::Organizations.current_id = organization.id
    dummy_selected_offer = FactoryBot.build(:multi_currency_selected_offer, trip_id: shipment.trip_id)
    consolidated_selected_offer = FactoryBot.build(:consolidated_selected_offer, trip_id: shipment.trip_id)
    allow(shipment).to receive(:selected_offer).and_return(dummy_selected_offer)
    allow(agg_shipment).to receive(:selected_offer).and_return(consolidated_selected_offer)
  end

  context 'with helper methods' do
    let!(:scope) do
      FactoryBot.create(:organizations_scope, target: organization, content: {
               hide_converted_grand_total: true,
               fine_fee_detail: true,
               chargeable_weight_view: 'weight'
             })
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
