# frozen_string_literal: true

module Ledger
  class Delta < ApplicationRecord
    belongs_to :fee, class_name: 'Ledger::Fee'
    belongs_to :target, polymorphic: true, optional: true
    enum operator: { addition: 0, percentage: 1 }
    enum rate_basis: { wm: 0, cbm: 1, kg: 2, unit: 3, km: 4, stowage: 5, flat: 6 }

    MAX_VALUE = (1 << 63) - 1
  end
end

# == Schema Information
#
# Table name: ledger_delta
#
#  id                  :uuid             not null, primary key
#  amount_cents        :bigint           default(0), not null
#  amount_currency     :string           not null
#  fee_id              :uuid
#  rate_basis          :integer          default("wm"), not null
#  kg_range            :numrange
#  stowage_range       :numrange
#  km_range            :numrange
#  cbm_range           :numrange
#  wm_range            :numrange
#  unit_range          :numrange
#  min_amount_cents    :bigint           default(0), not null
#  min_amount_currency :string           not null
#  max_amount_cents    :bigint           default(0), not null
#  max_amount_currency :string           not null
#  wm_ratio            :decimal(, )      default(1000.0)
#  operator            :integer          default("addition"), not null
#  level               :integer          default(0), not null
#  target_type         :string
#  target_id           :uuid
#  validity            :daterange
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
