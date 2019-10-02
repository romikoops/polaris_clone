# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pricing, type: :model do
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
#  id                    :bigint           not null, primary key
#  wm_rate               :decimal(, )
#  effective_date        :datetime
#  expiration_date       :datetime
#  tenant_id             :bigint
#  transport_category_id :bigint
#  user_id               :bigint
#  itinerary_id          :bigint
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  tenant_vehicle_id     :integer
#  uuid                  :uuid
#  sandbox_id            :uuid
#  internal              :boolean          default(FALSE)
#
