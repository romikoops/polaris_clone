# frozen_string_literal: true

module Legacy
  class ChargeBreakdown < ApplicationRecord
    self.table_name = 'charge_breakdowns'

    belongs_to :shipment
    belongs_to :tender, class_name: 'Quotations::Tender', optional: true
    belongs_to :trip
    belongs_to :pickup_tenant_vehicle, class_name: 'Legacy::TenantVehicle', optional: true
    belongs_to :freight_tenant_vehicle, class_name: 'Legacy::TenantVehicle'
    belongs_to :delivery_tenant_vehicle, class_name: 'Legacy::TenantVehicle', optional: true
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    validates :freight_tenant_vehicle, uniqueness: {
      scope: %i[trip_id shipment_id pickup_tenant_vehicle delivery_tenant_vehicle]
    }

    has_many :charges, dependent: :destroy do
      def from_category(charge_category)
        where(charge_category: ChargeCategory.where(code: charge_category))
      end
    end

    has_many :charge_categories, through: :charges do
      def detail(level = 0)
        where('charges.detail_level': level).uniq
      end
    end

    scope :selected, lambda {
      joins(:shipment).where('charge_breakdowns.trip_id = shipments.trip_id').first
    }

    def charge(charge_category)
      charges.where(children_charge_category: ChargeCategory.where(code: charge_category)).first
    end

    def grand_total
      charge('grand_total')
    end

    def grand_total=(value)
      grand_total&.delete
      charges << value
    end

    def currency_count
      Legacy::Price.where(id: charges.select(:price_id)).select(:currency).distinct.count
    end

    def to_nested_hash(args, sub_total_charge: false)
      grand_total.deconstruct_tree_into_schedule_charge(args,
                                                        sub_total_charge: sub_total_charge)
                 .merge(trip_id: trip_id, valid_until: valid_until)
                 .deep_stringify_keys
    end

    def dup_charges(charge_breakdown:)
      charge_breakdown.grand_total.dup_tree(charge_breakdown: self)
    end
  end
end

# == Schema Information
#
# Table name: charge_breakdowns
#
#  id                         :bigint           not null, primary key
#  valid_until                :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  delivery_tenant_vehicle_id :integer
#  freight_tenant_vehicle_id  :integer
#  pickup_tenant_vehicle_id   :integer
#  sandbox_id                 :uuid
#  shipment_id                :integer
#  tender_id                  :uuid
#  trip_id                    :integer
#
# Indexes
#
#  index_charge_breakdowns_on_sandbox_id  (sandbox_id)
#
# Foreign Keys
#
#  fk_rails_...  (delivery_tenant_vehicle_id => tenant_vehicles.id)
#  fk_rails_...  (freight_tenant_vehicle_id => tenant_vehicles.id)
#  fk_rails_...  (pickup_tenant_vehicle_id => tenant_vehicles.id)
#
