# frozen_string_literal: true

module Rates
  class Fee < ApplicationRecord
    enum operator: { addition: 0, percentage: 1 }
    enum rate_basis: {
      shipment: 0,
      wm: 1,
      bill: 2,
      cbm: 3,
      kg: 4,
      stowage: 5,
      unit: 6,
      km: 7
    }

    belongs_to :cargo

    belongs_to :target, polymorphic: true, optional: true
  end
end

# == Schema Information
#
# Table name: rates_fees
#
#  id                  :uuid             not null, primary key
#  amount_cents        :bigint           default(0), not null
#  amount_currency     :string           not null
#  cbm_range           :numrange
#  cbm_ratio           :decimal(, )      default(1000.0)
#  kg_range            :numrange
#  km_range            :numrange
#  level               :integer          default(0), not null
#  max_amount_cents    :bigint           default(0), not null
#  max_amount_currency :string           not null
#  min_amount_cents    :bigint           default(0), not null
#  min_amount_currency :string           not null
#  operator            :integer          default("addition"), not null
#  rate_basis          :integer          default("shipment"), not null
#  rule                :jsonb
#  stowage_range       :numrange
#  unit_range          :numrange
#  validity            :daterange
#  wm_range            :numrange
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  cargo_id            :uuid
#
# Indexes
#
#  index_rates_fees_on_cargo_id  (cargo_id)
#
# Foreign Keys
#
#  fk_rails_...  (cargo_id => rates_cargos.id)
#
