# frozen_string_literal: true

FactoryBot.define do
  factory :tenants_company, class: 'Tenants::Company' do
    name { 'ItsMyCargo GmbH' }
    sequence(:email) { |n| "admin#{n}@itsmycargo.test" }
    vat_number { '123456789' }
    association :organization, factory: :organizations_organization
  end
end

# == Schema Information
#
# Table name: tenants_companies
#
#  id              :uuid             not null, primary key
#  deleted_at      :datetime
#  email           :string
#  name            :string
#  phone           :string
#  vat_number      :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  address_id      :integer
#  external_id     :string
#  organization_id :uuid
#  sandbox_id      :uuid
#  tenant_id       :uuid
#
# Indexes
#
#  index_tenants_companies_on_organization_id  (organization_id)
#  index_tenants_companies_on_sandbox_id       (sandbox_id)
#  index_tenants_companies_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
