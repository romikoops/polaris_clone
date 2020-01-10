# frozen_string_literal: true

class Container < Legacy::Container
end

# == Schema Information
#
# Table name: containers
#
#  id              :bigint           not null, primary key
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
