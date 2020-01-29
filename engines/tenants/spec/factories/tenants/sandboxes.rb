FactoryBot.define do
  factory :tenants_sandbox, class: 'Sandbox' do
    
  end
end

# == Schema Information
#
# Table name: tenants_sandboxes
#
#  id         :uuid             not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :uuid
#
# Indexes
#
#  index_tenants_sandboxes_on_tenant_id  (tenant_id)
#
