# frozen_string_literal: true

FactoryBot.define do
  factory :shipments_cargo, class: 'Shipments::Cargo' do
    association :tenant, factory: :tenants_tenant

    total_goods_value_cents { 100_000 }
    total_goods_value_currency { :usd }
  end
end
