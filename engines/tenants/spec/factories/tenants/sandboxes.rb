FactoryBot.define do
  factory :tenants_sandbox, class: 'Sandbox' do
    
  end
end

# == Schema Information
#
# Table name: tenants_sandboxes
#
#  id              :uuid             not null, primary key
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#  tenant_id       :uuid
#
# Indexes
#
#  index_tenants_sandboxes_on_organization_id  (organization_id)
#  index_tenants_sandboxes_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
