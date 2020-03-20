# frozen_string_literal: true

module Quotations
  class Tender < ApplicationRecord
    belongs_to :quotation, inverse_of: :tenders
    belongs_to :origin_hub, class_name: 'Legacy::Hub'
    belongs_to :destination_hub, class_name: 'Legacy::Hub'
    belongs_to :tenant_vehicle, class_name: 'Legacy::TenantVehicle'
    belongs_to :itinerary, class_name: 'Legacy::Itinerary'
    has_one :charge_breakdown, class_name: 'Legacy::ChargeBreakdown'

    has_many :line_items, inverse_of: :tender

    monetize :amount_cents

    delegate :mode_of_transport, to: :tenant_vehicle
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
