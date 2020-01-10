# frozen_string_literal: true

module Legacy
  class ChargeBreakdown < ApplicationRecord
    self.table_name = 'charge_breakdowns'

    belongs_to :shipment
    belongs_to :trip
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    validates :trip_id, uniqueness: { scope: :shipment_id }

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

    def to_nested_hash
      grand_total.deconstruct_tree_into_schedule_charge
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
#  id          :bigint           not null, primary key
#  shipment_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  trip_id     :integer
#  sandbox_id  :uuid
#
