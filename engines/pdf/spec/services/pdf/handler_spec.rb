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
      it 'returns Trucking Rate as the name' do
        scope.update(content: scope.content.merge(consolidated_cargo: false))
        result = klass.extract_name(section_key: 'trucking_pre', name: 'Basic Trucking Freight', mot: 'ocean')
        expect(result).to eq('Trucking Rate')
      end

      it 'returns Ocean Freight as the name' do
        scope.update(content: scope.content.merge(consolidated_cargo: true))
        result = klass.extract_name(section_key: 'cargo', name: 'Basic Ocean Freight', mot: 'ocean')
        expect(result).to eq('Ocean Freight')
      end

      it 'returns Consolidated Freight Rate as the name' do
        scope.update(content: scope.content.merge(consolidated_cargo: true))
        result = klass.extract_name(section_key: 'cargo', name: 'Basic Trucking Freight', mot: 'depot')
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

    describe '.generate_fee_string' do
      let(:charge_shipment) {
        FactoryBot.create(:legacy_shipment,
          with_breakdown: true,
          organization: organization,
          with_tenders: true
        )
      }
      let(:quotes) { pdf_service.quotes_with_trip_id(quotation: nil, shipments: [charge_shipment]) }
      let(:string_klass) { described_class.new(default_args.merge(quotes: quotes, shipment: charge_shipment)) }

      before do
        FactoryBot.create(:organizations_theme, organization: organization)
      end

      it 'returns MOT Freight as key' do
        result = string_klass.generate_fee_string(quote: quotes.first, shipment: charge_shipment)
        expect(result).to eq('bas' => 'BAS - Basic Freight')
      end
    end
  end
end
