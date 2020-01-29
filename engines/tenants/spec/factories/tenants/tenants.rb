# frozen_string_literal: true

FactoryBot.define do
  factory :tenants_tenant, class: 'Tenants::Tenant' do
    sequence(:slug) { |n| "test_#{n}" }
  end
end

# == Schema Information
#
# Table name: tenants_tenants
#
#  id         :uuid             not null, primary key
#  slug       :string
#  subdomain  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  legacy_id  :integer
#
