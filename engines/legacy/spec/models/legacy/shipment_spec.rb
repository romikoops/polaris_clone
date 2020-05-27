# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Shipment, type: :model do
    let(:shipment) { FactoryBot.create(:legacy_shipment) }

    describe '#set_trucking_chargeable_weight' do
      it 'sets weight' do
        shipment.set_trucking_chargeable_weight('on_carriage', 10)
        expect(shipment.trucking['on_carriage']).to eq('truck_type' => '', 'chargeable_weight' => 10)
      end
    end

    describe '#cargo_classes' do
      it 'gets cargo classes' do
        shipment = FactoryBot.create(:legacy_shipment, load_type: 'container')

        expect(shipment.cargo_classes).to match(['fcl_20'])
      end

      it 'gets cargo classes for aggregated_cargo' do
        aggregated_cargo = FactoryBot.build(:legacy_aggregated_cargo)
        shipment = FactoryBot.build(:legacy_shipment, aggregated_cargo: aggregated_cargo)

        expect(shipment.cargo_classes).to match(['lcl'])
      end
    end

    describe '#has_carriage?' do
      it 'returns whether carriage exists' do
        has_carriage = shipment.has_carriage?('pre')
        expect(has_carriage).to be false
      end
    end

    describe '#valid_for_itinerary?' do
      let(:legacy_itinerary) { FactoryBot.create(:legacy_itinerary, :gothenburg_shanghai) }

      it 'returns whether carriage exists' do
        valid = shipment.valid_for_itinerary?(legacy_itinerary.id)
        expect(valid).to be true
      end
    end

    describe '#set_default_trucking' do
      it 'sets default trucking' do
        shipment.send('set_default_trucking')
        expect(shipment.trucking).to eq('on_carriage' => { 'truck_type' => '' }, 'pre_carriage' => { 'truck_type' => '' })
      end
    end

    describe '#set_default_planned_delivery_date' do
      it 'sets_default_planned_delivery_date' do
        shipment.send('set_default_planned_delivery_date')
        puts shipment.planned_delivery_date
        expect(shipment.planned_delivery_date.to_date).to eq (shipment.planned_delivery_date + 10).to_date
      end
    end

    describe '#desired_start_date_is_a_datetime?' do
      let(:shipment) { FactoryBot.create(:legacy_shipment, desired_start_date: Date.current) }

      it 'returns no errors' do
        shipment.send('desired_start_date_is_a_datetime?')
        expect(shipment.errors).to be_empty
      end
    end

    describe '#user_tenant_match' do
      it 'returns error if match' do
        shipment.send('user_tenant_match')
        expect(shipment.errors.count).to eq 1
      end
    end

    describe '#itinerary_trip_match' do
      let(:shipment) { FactoryBot.create(:legacy_shipment, itinerary_id: trip.itinerary_id) }
      let(:trip) { FactoryBot.create(:legacy_trip) }

      it 'returns error if match' do
        shipment.send('itinerary_trip_match')
        expect(shipment.errors.count).to eq 1
      end
    end

    describe '#before_validations' do
      it 'set default trucking before validation' do
        expect { shipment.validate! }.not_to raise_error
      end
    end

    describe 'lcl?' do
      let(:shipment) { FactoryBot.build(:legacy_shipment, load_type: 'cargo_item') }

      it 'return true for lcl' do
        expect(shipment.lcl?).to be(true)
      end
    end

    describe 'fcl?' do
      let(:shipment) { FactoryBot.build(:legacy_shipment, load_type: 'container') }

      it 'return true for fcl?' do
        expect(shipment.fcl?).to be(true)
      end
    end

    describe 'service_level' do
      it 'returns the service level from the trip' do
        expect(shipment.service_level).to be(shipment.trip.tenant_vehicle.name)
      end
    end

    describe 'vessel_name' do
      it 'returns the vessel name from the trip' do
        expect(shipment.vessel_name).to be(shipment.trip.vessel)
      end
    end

    describe 'voyage_code' do
      it 'returns the voyage code from the trip' do
        expect(shipment.voyage_code).to be(shipment.trip.voyage_code)
      end
    end
    describe 'carrier' do
      it 'returns the carrier from the trip' do
        expect(shipment.carrier).to be(shipment.trip.tenant_vehicle.carrier&.name)
      end
    end
  end
end

# == Schema Information
#
# Table name: shipments
#
#  id                                  :bigint           not null, primary key
#  booking_placed_at                   :datetime
#  cargo_notes                         :string
#  closing_date                        :datetime
#  customs                             :jsonb
#  customs_credit                      :boolean          default(FALSE)
#  deleted_at                          :datetime
#  desired_start_date                  :datetime
#  direction                           :string
#  eori                                :string
#  has_on_carriage                     :boolean
#  has_pre_carriage                    :boolean
#  imc_reference                       :string
#  incoterm_text                       :string
#  insurance                           :jsonb
#  load_type                           :string
#  meta                                :jsonb
#  notes                               :string
#  planned_delivery_date               :datetime
#  planned_destination_collection_date :datetime
#  planned_eta                         :datetime
#  planned_etd                         :datetime
#  planned_origin_drop_off_date        :datetime
#  planned_pickup_date                 :datetime
#  status                              :string
#  total_goods_value                   :jsonb
#  trucking                            :jsonb
#  uuid                                :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  destination_hub_id                  :integer
#  destination_nexus_id                :integer
#  incoterm_id                         :integer
#  itinerary_id                        :integer
#  origin_hub_id                       :integer
#  origin_nexus_id                     :integer
#  quotation_id                        :integer
#  sandbox_id                          :uuid
#  tenant_id                           :integer
#  tender_id                           :uuid
#  trip_id                             :integer
#  user_id                             :integer
#
# Indexes
#
#  index_shipments_on_sandbox_id  (sandbox_id) WHERE (deleted_at IS NULL)
#  index_shipments_on_tenant_id   (tenant_id) WHERE (deleted_at IS NULL)
#  index_shipments_on_tender_id   (tender_id)
#
