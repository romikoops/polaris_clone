# frozen_string_literal: true

FactoryBot.define do
  factory :tenants_domain, class: 'Tenants::Domain' do
    association :tenant, factory: :tenants_tenant

    sequence(:domain) { |n| "test#{n}.example" }
    default { false }
  end
end

# == Schema Information
#
# Table name: tenants_domains
#
#  id         :uuid             not null, primary key
#  default    :boolean
#  domain     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :uuid
#
# Indexes
#
#  index_tenants_domains_on_tenant_id  (tenant_id)
#
