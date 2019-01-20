# frozen_string_literal: true

FactoryBot.define do
  factory :shipment do
    association :user
    association :origin_hub, factory: :hub
    association :destination_hub, factory: :hub
    association :trip
    load_type { :container }
    booking_placed_at { Date.today }
    planned_etd { Date.tomorrow + 7.days + 2.hours }
    planned_eta { Date.tomorrow + 11.days }
    closing_date { Date.tomorrow + 4.days + 5.hours }

    total_goods_value do
      {
        value: 100,
        currency: :EUR
      }
    end

    transient do
      with_breakdown { false }
    end

    before(:create) do |shipment, evaluator|
      shipment.itinerary_id = shipment.trip.itinerary_id if shipment.itinerary.nil?

      shipment.origin_nexus = shipment.origin_hub.nexus
      shipment.destination_nexus = shipment.destination_hub.nexus

      shipment.shipment_contacts << build(:shipment_contact, shipment: shipment, contact_type: :shipper)
      shipment.shipment_contacts << build(:shipment_contact, shipment: shipment, contact_type: :consignee)

      if evaluator.with_breakdown
        shipment.charge_breakdowns << create(:charge_breakdown, trip: shipment.trip, shipment: shipment)
      end
    end
  end
end

# == Schema Information
#
# Table name: shipments
#
#  id                                  :bigint(8)        not null, primary key
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
#  transport_category_id               :bigint(8)
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
#
