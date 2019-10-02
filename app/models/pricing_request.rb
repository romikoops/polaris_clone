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
#  pricing_id :integer
#  user_id    :integer
#  tenant_id  :integer
#  status     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
