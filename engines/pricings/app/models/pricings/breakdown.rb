# frozen_string_literal: true

module Pricings
  class Breakdown < ApplicationRecord
    belongs_to :margin, optional: true
    belongs_to :metadatum
    belongs_to :cargo_unit, polymorphic: true, optional: true
    belongs_to :target, polymorphic: true, optional: true

    def code
      ::Legacy::ChargeCategory.find(charge_category_id)&.code
    end

    def target_name
      target.try(:name)
    end
  end
end

# == Schema Information
#
# Table name: pricings_breakdowns
#
#  id                 :uuid             not null, primary key
#  metadatum_id       :uuid             not null
#  pricing_id         :string
#  cargo_class        :string
#  margin_id          :uuid
#  data               :jsonb
#  target_type        :string
#  target_id          :uuid
#  cargo_unit_type    :string
#  cargo_unit_id      :bigint
#  charge_category_id :integer
#  charge_id          :integer
#  rate_origin        :jsonb
#  order              :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
