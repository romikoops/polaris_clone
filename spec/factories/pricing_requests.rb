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
#  pricing_id :integer
#  user_id    :integer
#  tenant_id  :integer
#  status     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
