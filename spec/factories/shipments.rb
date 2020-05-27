# frozen_string_literal: true

FactoryBot.define do
  factory :shipment do
    association :user, with_profile: true
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
      with_full_breakdown { false }
      with_aggregated_cargo { false }
    end


    trait :with_contacts do
      after(:build) do |shipment|
        shipment.shipment_contacts << build(:shipment_contact, contact_type: :shipper)
        shipment.shipment_contacts << build(:shipment_contact, contact_type: :consignee)
        shipment.shipment_contacts << build_list(:shipment_contact, 2, contact_type: :notifyee)
      end
    end

    before(:create) do |shipment, evaluator|
      shipment.itinerary_id = shipment.trip.itinerary_id if shipment.itinerary.nil?

      shipment.origin_nexus = shipment.origin_hub.nexus
      shipment.destination_nexus = shipment.destination_hub.nexus

      if evaluator.with_aggregated_cargo
        create(:aggregated_cargo, shipment: shipment)
      else
        shipment.cargo_units << create("#{shipment.load_type}".to_sym, shipment: shipment)
      end

      if evaluator.with_breakdown
        shipment.charge_breakdowns << create(:charge_breakdown, trip: shipment.trip, shipment: shipment)
      end
    end

    factory :complete_shipment, traits: %i(with_contacts)
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
