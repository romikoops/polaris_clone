# frozen_string_literal: true

FactoryBot.define do
  factory :tenants_theme, class: 'Tenants::Theme' do
    association :tenant, factory: :tenants_tenant
    primary_color { '#F5F5F5' }
    secondary_color { '#F5F5F5' }
    bright_primary_color { '#F5F5F5' }
    bright_secondary_color { '#F5F5F5' }
  end
end
