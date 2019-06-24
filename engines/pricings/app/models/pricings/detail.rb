# frozen_string_literal: true

module Pricings
  class Detail < ApplicationRecord
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    belongs_to :margin
    belongs_to :charge_category, class_name: 'Legacy::ChargeCategory'

    def rate_basis
      margin.get_pricing&.fees&.find_by(charge_category_id: charge_category_id)&.rate_basis&.external_code
    end

    def itinerary_name
      margin.itinerary_name
    end

    def fee_code
      charge_category&.code
    end
  end
end

# == Schema Information
#
# Table name: pricings_details
#
#  id                 :uuid             not null, primary key
#  tenant_id          :uuid
#  margin_id          :uuid
#  value              :decimal(, )
#  operator           :string
#  charge_category_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
