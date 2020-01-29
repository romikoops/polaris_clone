# frozen_string_literal: true

module Ledger
  class Fee < ApplicationRecord
    belongs_to :rate, class_name: 'Ledger::Rate'
    has_many :deltas, class_name: 'Ledger::Delta'
    enum cargo_class: Cargo::Specification::CLASS_ENUM, _prefix: true
    enum cargo_type: Cargo::Specification::TYPE_ENUM, _prefix: true
    enum action: { nothing: 0, min_value: 1, max_value: 2, sum_values: 3, total: 4 }
    enum applicable: { self: 0, section: 1, shipment: 2 }
    enum load_meterage_logic: { regular: 0, comparative: 1, consolidated: 2 }
    enum load_meterage_type: { height: 0, area: 1, stacked_area: 2, load_meters: 3 }

    def carriage
      target = rate.target
      route = target.try(:route)
      return if route&.mode_of_transport != 'carriage'

      route.origin_terminal_id ? :on : :pre
    end
  end
end

# == Schema Information
#
# Table name: ledger_fees
#
#  id                  :uuid             not null, primary key
#  action              :integer          default("nothing")
#  applicable          :integer          default("self")
#  base                :decimal(, )      default(0.000001)
#  cargo_class         :bigint           default("00")
#  cargo_type          :bigint           default("LCL")
#  category            :integer          default(0)
#  code                :string
#  load_meterage_limit :decimal(, )      default(0.0)
#  load_meterage_logic :integer          default("regular")
#  load_meterage_ratio :decimal(, )      default(0.0)
#  load_meterage_type  :integer          default("height")
#  order               :integer          default(0)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  rate_id             :uuid
#
# Indexes
#
#  index_ledger_fees_on_cargo_class  (cargo_class)
#  index_ledger_fees_on_cargo_type   (cargo_type)
#  index_ledger_fees_on_category     (category)
#  index_ledger_fees_on_rate_id      (rate_id)
#
