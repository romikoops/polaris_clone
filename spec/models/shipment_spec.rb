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
#  booking_placed_at                   :datetime
#  cargo_notes                         :string
#  closing_date                        :datetime
#  customs                             :jsonb
#  customs_credit                      :boolean          default(FALSE)
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
#  transport_category_id               :bigint
#  trip_id                             :integer
#  user_id                             :integer
#
# Indexes
#
#  index_shipments_on_sandbox_id             (sandbox_id)
#  index_shipments_on_tenant_id              (tenant_id)
#  index_shipments_on_transport_category_id  (transport_category_id)
#
# Foreign Keys
#
#  fk_rails_...  (transport_category_id => transport_categories.id)
#
