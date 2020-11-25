module Journey
  class CommodityInfo < ApplicationRecord
    belongs_to :cargo_unit

    validates :hs_code, presence: true
    validates :imo_class, presence: true, format: {
      with: /\A[1-9]\z|\A[1-9].[1-7]\z/
    }
    validates :description, presence: true
  end
end

# == Schema Information
#
# Table name: journey_commodity_infos
#
#  id            :uuid             not null, primary key
#  description   :string           default(""), not null
#  hs_code       :string
#  imo_class     :string           default(""), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  cargo_unit_id :uuid
#
# Indexes
#
#  index_journey_commodity_infos_on_cargo_unit_id  (cargo_unit_id)
#
# Foreign Keys
#
#  fk_rails_...  (cargo_unit_id => journey_cargo_units.id) ON DELETE => cascade
#
