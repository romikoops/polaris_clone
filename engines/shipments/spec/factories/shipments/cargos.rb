# frozen_string_literal: true

FactoryBot.define do
  factory :shipments_cargo, class: 'Shipments::Cargo' do
    association :tenant, factory: :tenants_tenant

    total_goods_value_cents { 100_000 }
    total_goods_value_currency { :usd }
  end
end

# == Schema Information
#
# Table name: shipments_cargos
#
#  id                         :uuid             not null, primary key
#  total_goods_value_cents    :integer          default(0), not null
#  total_goods_value_currency :string           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  sandbox_id                 :uuid
#  shipment_id                :uuid
#  tenant_id                  :uuid
#
# Indexes
#
#  index_shipments_cargos_on_sandbox_id   (sandbox_id)
#  index_shipments_cargos_on_shipment_id  (shipment_id)
#  index_shipments_cargos_on_tenant_id    (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (sandbox_id => tenants_sandboxes.id)
#  fk_rails_...  (tenant_id => tenants_tenants.id)
#
