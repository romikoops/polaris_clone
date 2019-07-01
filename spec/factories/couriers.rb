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
#  id         :bigint(8)        not null, primary key
#  name       :string
#  tenant_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#
