# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_shipment, class: "Legacy::Shipment" do
    transient do
      with_breakdown { false }
      with_full_breakdown { false }
      with_tenders { false }
      with_aggregated_cargo { false }
      custom_cargo_classes {}
      completed { false }
      breakdown_count { 1 }
    end

    user { association(:users_client) }
    origin_hub { association(:legacy_hub) }
    destination_hub { association(:legacy_hub) }
    trip { association(:legacy_trip) }
    organization { association(:organizations_organization) }

    load_type { :container }
    booking_placed_at { Time.zone.today }
    planned_etd { Date.tomorrow + 7.days + 2.hours }
    planned_eta { Date.tomorrow + 11.days }
    closing_date { Date.tomorrow + 4.days + 5.hours }
    sequence(:imc_reference) { |n| "#{SecureRandom.hex}#{n}" }
    has_pre_carriage { false }
    has_on_carriage { false }
    billing { :external }
    total_goods_value do
      {
        value: 100,
        currency: :EUR
      }
    end

    trait :with_contacts do
      after(:build) do |shipment|
        shipment.shipment_contacts << build(:legacy_shipment_contact, contact_type: :shipper)
        shipment.shipment_contacts << build(:legacy_shipment_contact, contact_type: :consignee)
        shipment.shipment_contacts << build_list(:legacy_shipment_contact, 2, contact_type: :notifyee)
      end
    end

    trait :without_notifyee do
      after(:build) do |shipment|
        shipment.shipment_contacts << build(:legacy_shipment_contact, contact_type: :shipper)
        shipment.shipment_contacts << build(:legacy_shipment_contact, contact_type: :consignee)
      end
    end

    trait :with_meta do
      after(:build) do |shipment|
        shipment.meta = {
          'pricing_rate_data': {
            "lcl": {
              "bas": {
                "min": "7.0",
                "base": nil,
                "rate": "7.0",
                "range": [],
                "currency": "USD",
                "rate_basis": "PER_WM",
                "hw_threshold": nil,
                "hw_rate_basis": nil
              },
              "total": {
                "value": "7.0",
                "currency": "USD"
              },
              "valid_until": "2020-12-31T23:59:59.000Z"
            }
          }
        }
      end
    end

    trait :with_hubs do
      after(:create) do |shipment|
        shipment.origin_hub = shipment.itinerary.origin_hub if shipment.itinerary.present?
        shipment.destination_hub = shipment.itinerary.destination_hub if shipment.itinerary.present?
        shipment.origin_nexus = shipment.origin_hub.nexus if shipment.origin_hub.present?
        shipment.destination_nexus = shipment.destination_hub.nexus if shipment.destination_hub.present?
      end
    end

    before(:create) do |shipment, evaluator|
      shipment.itinerary_id = shipment.trip.itinerary_id if shipment.itinerary.nil?
      shipment.origin_nexus = shipment.origin_hub.nexus if shipment.origin_hub.present?
      shipment.destination_nexus = shipment.destination_hub.nexus if shipment.destination_hub.present?
      if evaluator.with_tenders
        quotation = FactoryBot.create(:quotations_quotation,
          shipment.load_type.to_sym,
          origin_nexus: shipment.origin_nexus,
          destination_nexus: shipment.destination_nexus,
          user: shipment.user,
          created_at: shipment.created_at,
          legacy_shipment: shipment,
          completed: evaluator.completed,
          organization: shipment.organization)
      end
      if evaluator.with_aggregated_cargo
        create(:legacy_aggregated_cargo, shipment: shipment)
      elsif evaluator.custom_cargo_classes
        shipment.cargo_units = evaluator.custom_cargo_classes.map do |cargo_class|
          create("#{cargo_class}_#{shipment.load_type}".to_sym, shipment: shipment)
        end
      else
        shipment.cargo_units << create("legacy_#{shipment.load_type}".to_sym, shipment: shipment)
      end

      if evaluator.with_breakdown || evaluator.with_full_breakdown
        sections = evaluator.with_full_breakdown ? %w[trucking_pre export cargo import trucking_on] : ["cargo"]
        breakdowns = create_list(:legacy_charge_breakdown,
          evaluator.breakdown_count,
          trip: shipment.trip || create(:legacy_trip, itinerary: shipment.itinerary),
          shipment: shipment,
          with_tender: evaluator.with_tenders,
          sections: sections,
          quotation: quotation)

        shipment.charge_breakdowns = breakdowns
      end
    end

    trait :completed do
      transient do
        with_breakdown { true }
        with_full_breakdown { false }
        with_tenders { true }
        with_aggregated_cargo { false }
        completed { true }
      end

      after(:create) do |shipment|
        chosen_breakdown = shipment.charge_breakdowns.first
        chosen_tender = chosen_breakdown.tender
        shipment.update(
          trip: shipment.charge_breakdowns.first.trip,
          tender_id: chosen_tender.id,
          imc_reference: chosen_tender.imc_reference
        )
      end
    end

    factory :complete_legacy_shipment, traits: %i[with_contacts with_hubs]
    factory :legacy_shipment_without_notifyee, traits: %i[without_notifyee with_hubs]
    factory :completed_legacy_shipment, traits: %i[with_contacts with_hubs with_meta completed]
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
#  distinct_id                         :uuid
#  incoterm_id                         :integer
#  itinerary_id                        :integer
#  old_user_id                         :integer
#  organization_id                     :uuid
#  origin_hub_id                       :integer
#  origin_nexus_id                     :integer
#  quotation_id                        :integer
#  sandbox_id                          :uuid
#  tenant_id                           :integer
#  tender_id                           :uuid
#  trip_id                             :integer
#  user_id                             :uuid
#
# Indexes
#
#  index_shipments_on_organization_id  (organization_id)
#  index_shipments_on_sandbox_id       (sandbox_id) WHERE (deleted_at IS NULL)
#  index_shipments_on_tenant_id        (tenant_id) WHERE (deleted_at IS NULL)
#  index_shipments_on_tender_id        (tender_id)
#  index_shipments_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_     (user_id => users_users.id)
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (transport_category_id => transport_categories_20200504.id)
#
