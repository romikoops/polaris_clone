# frozen_string_literal: true

FactoryBot.define do
  factory :quotations_tender, class: "Quotations::Tender" do
    carrier_name { "Sealand" }
    load_type { "container" }
    amount_cents { 30 }
    amount_currency { "USD" }
    original_amount_cents { 30 }
    original_amount_currency { "USD" }
    association :quotation, factory: :quotations_quotation
    origin_hub do
      association :legacy_hub, organization: instance.quotation.organization
    end
    destination_hub do
      association :legacy_hub, organization: instance.quotation.organization
    end
    itinerary do
      association :legacy_itinerary, origin_hub: instance.origin_hub, destination_hub: instance.destination_hub, organization: instance.quotation.organization
    end
    tenant_vehicle do
      association :legacy_tenant_vehicle, organization: instance.quotation.organization
    end
  end
end

# == Schema Information
#
# Table name: quotations_tenders
#
#  id                         :uuid             not null, primary key
#  amount_cents               :integer
#  amount_currency            :string
#  carrier_name               :string
#  load_type                  :string
#  name                       :string
#  original_amount_cents      :integer
#  original_amount_currency   :string
#  transshipment              :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  delivery_tenant_vehicle_id :integer
#  destination_hub_id         :integer
#  itinerary_id               :integer
#  origin_hub_id              :integer
#  pickup_tenant_vehicle_id   :integer
#  quotation_id               :uuid
#  tenant_vehicle_id          :bigint
#
# Indexes
#
#  index_quotations_tenders_on_delivery_tenant_vehicle_id  (delivery_tenant_vehicle_id)
#  index_quotations_tenders_on_destination_hub_id          (destination_hub_id)
#  index_quotations_tenders_on_origin_hub_id               (origin_hub_id)
#  index_quotations_tenders_on_pickup_tenant_vehicle_id    (pickup_tenant_vehicle_id)
#  index_quotations_tenders_on_quotation_id                (quotation_id)
#  index_quotations_tenders_on_tenant_vehicle_id           (tenant_vehicle_id)
#
# Foreign Keys
#
#  fk_rails_...  (delivery_tenant_vehicle_id => tenant_vehicles.id)
#  fk_rails_...  (pickup_tenant_vehicle_id => tenant_vehicles.id)
#  fk_rails_...  (quotation_id => quotations_quotations.id)
#
