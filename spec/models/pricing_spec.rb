# frozen_string_literal: true


require 'rails_helper'

describe Pricing, type: :model do
  subject { create(:pricing) }

  context 'validations' do
    let(:duplicate_pricing) { subject.dup }

    it 'validates uniqueness' do
      expect(duplicate_pricing).not_to be_valid
    end
  end
end

# == Schema Information
#
# Table name: pricings
#
#  id                    :bigint(8)        not null, primary key
#  wm_rate               :decimal(, )
#  effective_date        :datetime
#  expiration_date       :datetime
#  tenant_id             :bigint(8)
#  transport_category_id :bigint(8)
#  user_id               :bigint(8)
#  itinerary_id          :bigint(8)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  tenant_vehicle_id     :integer
#
