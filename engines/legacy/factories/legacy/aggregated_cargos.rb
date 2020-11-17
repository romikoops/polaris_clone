# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_aggregated_cargo, class: 'Legacy::AggregatedCargo' do
    association :shipment, factory: :legacy_shipment

    weight { 200 }
    volume { 1.0 }
    chargeable_weight { 1000 }
  end
end

# == Schema Information
#
# Table name: aggregated_cargos
#
#  id                :bigint           not null, primary key
#  chargeable_weight :decimal(, )
#  volume            :decimal(, )
#  weight            :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sandbox_id        :uuid
#  shipment_id       :integer
#
# Indexes
#
#  index_aggregated_cargos_on_sandbox_id  (sandbox_id)
#
