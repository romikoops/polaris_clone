# frozen_string_literal: true

FactoryBot.define do
  factory :courier do
    name { 'example courier' }
    association :tenant
  end
end

# == Schema Information
#
# Table name: couriers
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#  tenant_id  :integer
#
# Indexes
#
#  index_couriers_on_sandbox_id  (sandbox_id)
#  index_couriers_on_tenant_id   (tenant_id)
#
