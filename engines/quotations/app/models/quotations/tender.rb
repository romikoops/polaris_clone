# frozen_string_literal: true

module Quotations
  class Tender < ApplicationRecord
    belongs_to :quotation, inverse_of: :tenders
    belongs_to :origin_hub, class_name: 'Legacy::Hub'
    belongs_to :destination_hub, class_name: 'Legacy::Hub'
    belongs_to :tenant_vehicle, class_name: 'Legacy::TenantVehicle'
    belongs_to :pickup_tenant_vehicle, class_name: 'Legacy::TenantVehicle', optional: true
    belongs_to :delivery_tenant_vehicle, class_name: 'Legacy::TenantVehicle', optional: true
    belongs_to :itinerary, class_name: 'Legacy::Itinerary'
    has_one :charge_breakdown, class_name: 'Legacy::ChargeBreakdown'

    has_many :line_items, inverse_of: :tender

    monetize :amount_cents
    monetize :original_amount_cents

    delegate :mode_of_transport, to: :tenant_vehicle
    delegate :pickup_address, :delivery_address, :cargo, to: :quotation

    validates :tenant_vehicle, uniqueness: {
      scope: %i[quotation_id pickup_tenant_vehicle delivery_tenant_vehicle]
    }
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
