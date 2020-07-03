# frozen_string_literal: true

FactoryBot.define do
  factory :tenants_group, class: 'Groups::Group' do
    sequence(:name) { |n| "Example Group #{n}" }
    association :organization, factory: :organizations_organization
  end
end

# == Schema Information
#
# Table name: tenants_groups
#
#  id              :uuid             not null, primary key
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#  sandbox_id      :uuid
#  tenant_id       :uuid
#
# Indexes
#
#  index_tenants_groups_on_organization_id  (organization_id)
#  index_tenants_groups_on_sandbox_id       (sandbox_id)
#  index_tenants_groups_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
