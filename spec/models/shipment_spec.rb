# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shipment, type: :model do
  context 'Shipment with Charge breakdown' do
    let(:tenant) { build(:tenant) }
    let(:shipment) { create(:shipment, tenant: tenant, with_breakdown: true) }
    let(:other_trip) { create(:trip) }
    let!(:other_charge_breakdown) do
      create(:charge_breakdown,
             shipment: shipment,
             trip: other_trip,
             valid_until: 10.days.from_now.beginning_of_day,
             charge_category_name: 'Cargo1')
    end

    describe '.valid_until' do
      it 'returns the Charge Breakdown valid_until value for the shipment trip' do
        expect(shipment.valid_until(shipment.trip)).to eq(4.days.from_now.beginning_of_day)
      end

      it 'returns the Charge Breakdown valid_until value a different trip' do
        expect(shipment.valid_until(other_trip)).to eq(10.days.from_now.beginning_of_day)
      end
    end
  end
end

# == Schema Information
#
# Table name: shipments
#
#  id                                  :bigint           not null, primary key
#  user_id                             :integer
#  uuid                                :string
#  imc_reference                       :string
#  status                              :string
#  load_type                           :string
#  planned_pickup_date                 :datetime
#  has_pre_carriage                    :boolean
#  has_on_carriage                     :boolean
#  cargo_notes                         :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  tenant_id                           :integer
#  planned_eta                         :datetime
#  planned_etd                         :datetime
#  itinerary_id                        :integer
#  trucking                            :jsonb
#  customs_credit                      :boolean          default(FALSE)
#  total_goods_value                   :jsonb
#  trip_id                             :integer
#  eori                                :string
#  direction                           :string
#  notes                               :string
#  origin_hub_id                       :integer
#  destination_hub_id                  :integer
#  booking_placed_at                   :datetime
#  insurance                           :jsonb
#  customs                             :jsonb
#  transport_category_id               :bigint
#  incoterm_id                         :integer
#  closing_date                        :datetime
#  incoterm_text                       :string
#  origin_nexus_id                     :integer
#  destination_nexus_id                :integer
#  planned_origin_drop_off_date        :datetime
#  quotation_id                        :integer
#  planned_delivery_date               :datetime
#  planned_destination_collection_date :datetime
#  desired_start_date                  :datetime
#  meta                                :jsonb
#  sandbox_id                          :uuid
#
