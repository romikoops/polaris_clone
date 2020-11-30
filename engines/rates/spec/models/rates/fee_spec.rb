# frozen_string_literal: true

require "rails_helper"

module Rates
  RSpec.describe Fee, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:rates_fee)).to be_valid
    end
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
