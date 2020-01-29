# frozen_string_literal: true

FactoryBot.define do
  factory :pricing_request do
    association :pricing
    association :tenant
    status { 'requested' }
  end
end

# == Schema Information
#
# Table name: pricing_requests
#
#  id         :bigint           not null, primary key
#  status     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  pricing_id :integer
#  tenant_id  :integer
#  user_id    :integer
#
# Indexes
#
#  index_pricing_requests_on_pricing_id  (pricing_id)
#  index_pricing_requests_on_tenant_id   (tenant_id)
#  index_pricing_requests_on_user_id     (user_id)
#
