# frozen_string_literal: true

class PricingException < ApplicationRecord
  belongs_to :tenant
  belongs_to :pricing
  has_many :pricing_details, as: :priceable, dependent: :destroy

  def as_json(options = {})
    new_options = options.reverse_merge(
      methods: [:data], only: %i(effective_date expiration_date)
    )
    super(new_options)
  end

  def data
    pricing_details.map(&:as_json).reduce({}) { |hash, merged_hash| merged_hash.deep_merge(hash) }
  end
end

# == Schema Information
#
# Table name: pricing_exceptions
#
#  id              :bigint           not null, primary key
#  effective_date  :datetime
#  expiration_date :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  pricing_id      :bigint
#  tenant_id       :bigint
#
# Indexes
#
#  index_pricing_exceptions_on_pricing_id  (pricing_id)
#  index_pricing_exceptions_on_tenant_id   (tenant_id)
#
