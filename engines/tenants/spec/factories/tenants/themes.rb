# frozen_string_literal: true

FactoryBot.define do
  factory :tenants_theme, class: 'Tenants::Theme' do
    association :tenant, factory: :tenants_tenant
    primary_color { '#F5F5F5' }
    secondary_color { '#F8F8F8' }
    bright_primary_color { '#F6F6F6' }
    bright_secondary_color { '#F9F9F9' }
  end
end
