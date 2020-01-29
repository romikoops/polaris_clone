FactoryBot.define do
  factory :trucking_courier, class: 'Trucking::Courier' do
    name { 'example courier' }
    association :tenant, factory: :legacy_tenant
  end
end

# == Schema Information
#
# Table name: trucking_couriers
#
#  id         :uuid             not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#  tenant_id  :integer
#
# Indexes
#
#  index_trucking_couriers_on_sandbox_id  (sandbox_id)
#  index_trucking_couriers_on_tenant_id   (tenant_id)
#
