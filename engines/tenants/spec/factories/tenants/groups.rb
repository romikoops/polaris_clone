# frozen_string_literal: true

FactoryBot.define do
  factory :tenants_group, class: 'Tenants::Group' do
    association :tenant, factory: :tenants_tenants
  end
end

# == Schema Information
#
# Table name: tenants_groups
#
#  id         :uuid             not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#  tenant_id  :uuid
#
# Indexes
#
#  index_tenants_groups_on_sandbox_id  (sandbox_id)
#  index_tenants_groups_on_tenant_id   (tenant_id)
#
