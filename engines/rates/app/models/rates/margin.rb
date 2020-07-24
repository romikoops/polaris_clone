module Rates
  class Margin < ApplicationRecord
    belongs_to :organization, class_name: "Organizations::Organization"
    belongs_to :applicable_to, polymorphic: true
    belongs_to :target, polymorphic: true, optional: true

    enum operator: {addition: 0, multiplication: 1}
    enum rate_basis: {
      wm: 1,
      bill: 2,
      cbm: 3,
      kg: 4,
      stowage: 5,
      unit: 6,
      km: 7,
      percentage: 8
    }

    monetize :amount_cents
    monetize :min_amount_cents
    monetize :max_amount_cents
  end
end

# == Schema Information
#
# Table name: rates_margins
#
#  id                  :uuid             not null, primary key
#  amount_cents        :bigint           default(0), not null
#  amount_currency     :string           not null
#  applicable_to_type  :string
#  cargo_class         :integer          default(0)
#  cargo_type          :integer          default(0)
#  cbm_range           :numrange
#  cbm_ratio           :decimal(, )      default(1000.0)
#  kg_range            :numrange
#  km_range            :numrange
#  max_amount_cents    :bigint           default(0), not null
#  max_amount_currency :string           not null
#  min_amount_cents    :bigint           default(0), not null
#  min_amount_currency :string           not null
#  operator            :integer
#  order               :integer          default(0)
#  percentage          :decimal(, )
#  rate_basis          :integer          default(NULL), not null
#  stowage_range       :numrange
#  target_type         :string
#  unit_range          :numrange
#  validity            :daterange
#  wm_range            :numrange
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  applicable_to_id    :uuid
#  organization_id     :uuid
#  target_id           :uuid
#
# Indexes
#
#  index_rates_margins_on_applicable_to_type_and_applicable_to_id  (applicable_to_type,applicable_to_id)
#  index_rates_margins_on_cargo_class                              (cargo_class)
#  index_rates_margins_on_cargo_type                               (cargo_type)
#  index_rates_margins_on_organization_id                          (organization_id)
#  index_rates_margins_on_target_type_and_target_id                (target_type,target_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
