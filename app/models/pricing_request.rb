# frozen_string_literal: true

class PricingRequest < ApplicationRecord
  belongs_to :user
  belongs_to :tenant
  belongs_to :pricing
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
