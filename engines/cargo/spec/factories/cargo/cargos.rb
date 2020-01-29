# frozen_string_literal: true

FactoryBot.define do
  factory :cargo_cargo, class: 'Cargo::Cargo' do
    association :tenant, factory: :tenants_tenant

    total_goods_value_cents { 100_000 }
    total_goods_value_currency { :usd }
  end
end

# == Schema Information
#
# Table name: cargo_cargos
#
#  id                         :uuid             not null, primary key
#  total_goods_value_cents    :integer          default(0), not null
#  total_goods_value_currency :string           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  quotation_id               :uuid
#  tenant_id                  :uuid
#
# Indexes
#
#  index_cargo_cargos_on_quotation_id  (quotation_id)
#  index_cargo_cargos_on_tenant_id     (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (quotation_id => quotations_quotations.id)
#
