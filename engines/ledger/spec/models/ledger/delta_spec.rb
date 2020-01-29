# frozen_string_literal: true

require 'rails_helper'

module Ledger
  RSpec.describe Delta, type: :model do
    it 'builds a valid object' do
      expect(FactoryBot.build(:ledger_deltum)).to be_valid
    end
  end
end

# == Schema Information
#
# Table name: ledger_delta
#
#  id                  :uuid             not null, primary key
#  amount_cents        :bigint           default(0), not null
#  amount_currency     :string           not null
#  cbm_range           :numrange
#  kg_range            :numrange
#  km_range            :numrange
#  level               :integer          default(0), not null
#  max_amount_cents    :bigint           default(0), not null
#  max_amount_currency :string           not null
#  min_amount_cents    :bigint           default(0), not null
#  min_amount_currency :string           not null
#  operator            :integer          default("addition"), not null
#  rate_basis          :integer          default("wm"), not null
#  stowage_range       :numrange
#  target_type         :string
#  unit_range          :numrange
#  validity            :daterange
#  wm_range            :numrange
#  wm_ratio            :decimal(, )      default(1000.0)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  fee_id              :uuid
#  target_id           :uuid
#
# Indexes
#
#  index_ledger_delta_on_cbm_range      (cbm_range) USING gist
#  index_ledger_delta_on_fee_id         (fee_id)
#  index_ledger_delta_on_kg_range       (kg_range) USING gist
#  index_ledger_delta_on_km_range       (km_range) USING gist
#  index_ledger_delta_on_stowage_range  (stowage_range) USING gist
#  index_ledger_delta_on_unit_range     (unit_range) USING gist
#  index_ledger_delta_on_validity       (validity) USING gist
#  index_ledger_delta_on_wm_range       (wm_range) USING gist
#  ledger_delta_target_index            (target_type,target_id)
#
