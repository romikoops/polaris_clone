# frozen_string_literal: true

module Pricings
  class Breakdown < ApplicationRecord
    belongs_to :source, polymorphic: true, optional: true
    belongs_to :metadatum
    belongs_to :charge, class_name: "Legacy::Charge"
    belongs_to :charge_category, class_name: "Legacy::ChargeCategory"
    belongs_to :cargo_unit, polymorphic: true, optional: true
    belongs_to :target, polymorphic: true, optional: true
    validates :source_id, uniqueness: {scope: %i[charge_id charge_category_id metadatum_id]}

    belongs_to :margin, optional: true
    deprecate margin: "Converted to source"

    def code
      ::Legacy::ChargeCategory.find(charge_category_id)&.code
    end

    def target_name
      return target.try(:name) unless target.is_a?(Organizations::User)

      Profiles::ProfileDecorator.new(Profiles::Profile.find_by(user: target)).full_name
    end
  end
end

# == Schema Information
#
# Table name: pricings_breakdowns
#
#  id                 :uuid             not null, primary key
#  cargo_class        :string
#  cargo_unit_type    :string
#  data               :jsonb
#  order              :integer
#  rate_origin        :jsonb
#  source_type        :string
#  target_type        :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  cargo_unit_id      :bigint
#  charge_category_id :integer
#  charge_id          :integer
#  margin_id          :uuid
#  metadatum_id       :uuid             not null
#  pricing_id         :string
#  source_id          :uuid
#  target_id          :uuid
#
# Indexes
#
#  index_pricings_breakdowns_on_cargo_unit_type_and_cargo_unit_id  (cargo_unit_type,cargo_unit_id)
#  index_pricings_breakdowns_on_charge_category_id                 (charge_category_id)
#  index_pricings_breakdowns_on_charge_id                          (charge_id)
#  index_pricings_breakdowns_on_margin_id                          (margin_id)
#  index_pricings_breakdowns_on_metadatum_id                       (metadatum_id)
#  index_pricings_breakdowns_on_source_type_and_source_id          (source_type,source_id)
#  index_pricings_breakdowns_on_target_type_and_target_id          (target_type,target_id)
#
