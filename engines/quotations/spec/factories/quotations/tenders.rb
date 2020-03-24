# frozen_string_literal: true

FactoryBot.define do
  factory :quotations_tender, class: 'Quotations::Tender' do
    carrier_name { 'Sealand' }
    load_type { 'container' }
    amount_cents { 30 }
    amount_currency { 'USD' }
    association :quotation, factory: :quotations_quotation
    association :itinerary, factory: :gothenburg_shanghai_itinerary
    association :origin_hub, factory: :legacy_hub
    association :destination_hub, factory: :legacy_hub
    association :tenant_vehicle, factory: :legacy_tenant_vehicle
  end
end

# == Schema Information
#
# Table name: quotations_tenders
#
#  id                 :uuid             not null, primary key
#  amount_cents       :integer
#  amount_currency    :string
#  carrier_name       :string
#  load_type          :string
#  name               :string
#  transshipment      :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  destination_hub_id :integer
#  itinerary_id       :integer
#  origin_hub_id      :integer
#  quotation_id       :uuid
#  tenant_vehicle_id  :bigint
#
# Indexes
#
#  index_quotations_tenders_on_destination_hub_id  (destination_hub_id)
#  index_quotations_tenders_on_origin_hub_id       (origin_hub_id)
#  index_quotations_tenders_on_quotation_id        (quotation_id)
#  index_quotations_tenders_on_tenant_vehicle_id   (tenant_vehicle_id)
#
# Foreign Keys
#
#  fk_rails_...  (quotation_id => quotations_quotations.id)
#
