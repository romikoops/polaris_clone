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
    has_one :charge_breakdown, -> { with_deleted }, class_name: 'Legacy::ChargeBreakdown'

    has_many :line_items, inverse_of: :tender

    monetize :amount_cents
    monetize :original_amount_cents

    delegate :mode_of_transport, to: :tenant_vehicle
    delegate :pickup_address, :delivery_address, :cargo, to: :quotation
    delegate :valid_until, :trip, to: :charge_breakdown

    before_validation :generate_imc_reference, on: :create

    validates :tenant_vehicle, uniqueness: {
      scope: %i[quotation_id pickup_tenant_vehicle delivery_tenant_vehicle itinerary_id]
    }

    private

    def generate_imc_reference
      first_part = imc_reference_timestamp
      last_tender_in_this_hour = Quotations::Tender.where('imc_reference LIKE ?', first_part + '%')
        .order(:created_at).last
      if last_tender_in_this_hour
        last_serial_number = last_tender_in_this_hour.imc_reference[first_part.length..-1].to_i
        new_serial_number = last_serial_number + 1
        serial_code = new_serial_number.to_s.rjust(5, '0')
      else
        serial_code = '1'.rjust(5, '0')
      end

      self.imc_reference = first_part + serial_code
    end

    def imc_reference_timestamp
      now = DateTime.now
      day_of_the_year = now.strftime('%d%m')
      hour_as_letter = ('A'..'Z').to_a[now.hour - 1]
      year = now.year.to_s[-2..-1]
      day_of_the_year + hour_as_letter + year
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
#  delivery_truck_type        :string
#  imc_reference              :string
#  load_type                  :string
#  name                       :string
#  original_amount_cents      :integer
#  original_amount_currency   :string
#  pickup_truck_type          :string
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
