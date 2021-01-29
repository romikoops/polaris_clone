module Journey
  class CommodityInfo < ApplicationRecord
    VALID_IMO_CLASSES = %w[
      0
      1.1
      1.2
      1.3
      1.4
      1.5
      1.6
      2.1
      2.2
      2.3
      3
      4.1
      4.2
      4.3
      5.1
      5.2
      6.1
      6.2
      7.1
      7.2
      7.3
      7.4
      8
      9
    ].freeze
    belongs_to :cargo_unit

    validates :imo_class, inclusion: {in: VALID_IMO_CLASSES, message: "%{value} is not a valid IMO Class"}
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
