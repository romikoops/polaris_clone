# frozen_string_literal: true

FactoryBot.define do
  factory :tenants_domain, class: 'Tenants::Domain' do
    association :organization, factory: :organizations_organization

    sequence(:domain) { |n| "test#{n}.example" }
    default { false }
  end
end

# == Schema Information
#
# Table name: tenants_domains
#
#  id              :uuid             not null, primary key
#  default         :boolean
#  domain          :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#  tenant_id       :uuid
#
# Indexes
#
#  index_tenants_domains_on_organization_id  (organization_id)
#  index_tenants_domains_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
