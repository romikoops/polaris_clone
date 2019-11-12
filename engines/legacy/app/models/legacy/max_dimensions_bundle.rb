# frozen_string_literal: true

module Legacy
  class MaxDimensionsBundle < ApplicationRecord
    self.table_name = 'max_dimensions_bundles'
  end
end

# == Schema Information
#
# Table name: max_dimensions_bundles
#
#  id                :bigint           not null, primary key
#  mode_of_transport :string
#  tenant_id         :integer
#  aggregate         :boolean
#  dimension_x       :decimal(, )
#  dimension_y       :decimal(, )
#  dimension_z       :decimal(, )
#  payload_in_kg     :decimal(, )
#  chargeable_weight :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sandbox_id        :uuid
#
