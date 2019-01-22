# frozen_string_literal: true

FactoryBot.define do
  factory :max_dimensions_bundle do
    association :tenant
    mode_of_transport { 'general' }
    aggregate { false }
    dimension_x { '500' }
    dimension_y { '500' }
    dimension_z { '500' }
    payload_in_kg { '10_000' }
    chargeable_weight { '10_000' }
  end
end

# == Schema Information
#
# Table name: max_dimensions_bundles
#
#  id                :bigint(8)        not null, primary key
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
#
