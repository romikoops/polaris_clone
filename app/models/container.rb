# frozen_string_literal: true

class Container < Legacy::Container
end

# == Schema Information
#
# Table name: containers
#
#  id              :bigint           not null, primary key
#  cargo_class     :string
#  contents        :string
#  customs_text    :string
#  dangerous_goods :boolean
#  gross_weight    :decimal(, )
#  hs_codes        :string           default([]), is an Array
#  payload_in_kg   :decimal(, )
#  quantity        :integer
#  size_class      :string
#  tare_weight     :decimal(, )
#  unit_price      :jsonb
#  weight_class    :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  sandbox_id      :uuid
#  shipment_id     :integer
#
# Indexes
#
#  index_containers_on_sandbox_id  (sandbox_id)
#
