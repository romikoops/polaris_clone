# frozen_string_literal: true

module Legacy
  class Container < ApplicationRecord
    self.table_name = 'containers'
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    TARE_WEIGHTS = {
      fcl_20: 2370,
      fcl_40: 3750,
      fcl_40_hq: 4000
    }.freeze

    PRICING_WEIGHT_STEPS = [28.0, 24.0, 18.0, 14.0, 5.0].freeze
    CARGO_CLASSES = %w(
      fcl_10
      fcl_20
      fcl_20_ot
      fcl_20_rf
      fcl_20_frs
      fcl_20_frw
      fcl_40
      fcl_40_hq
      fcl_40_ot
      fcl_40_rf
      fcl_40_frs
      fcl_40_frw
      fcl_45
      fcl_45_hq
      fcl_45_rf
    )
    
    belongs_to :shipment, class_name: 'Legacy::Shipment'
  end
end

# == Schema Information
#
# Table name: containers
#
#  id              :bigint(8)        not null, primary key
#  shipment_id     :integer
#  size_class      :string
#  weight_class    :string
#  payload_in_kg   :decimal(, )
#  tare_weight     :decimal(, )
#  gross_weight    :decimal(, )
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  dangerous_goods :boolean
#  cargo_class     :string
#  hs_codes        :string           default([]), is an Array
#  customs_text    :string
#  quantity        :integer
#  unit_price      :jsonb
#  sandbox_id      :uuid
#
