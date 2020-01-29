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
#  effective_date        :datetime
#  expiration_date       :datetime
#  internal              :boolean          default(FALSE)
#  uuid                  :uuid
#  wm_rate               :decimal(, )
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  itinerary_id          :bigint
#  sandbox_id            :uuid
#  tenant_id             :bigint
#  tenant_vehicle_id     :integer
#  transport_category_id :bigint
#  user_id               :bigint
#
# Indexes
#
#  index_pricings_on_itinerary_id           (itinerary_id)
#  index_pricings_on_sandbox_id             (sandbox_id)
#  index_pricings_on_tenant_id              (tenant_id)
#  index_pricings_on_transport_category_id  (transport_category_id)
#  index_pricings_on_user_id                (user_id)
#  index_pricings_on_uuid                   (uuid) UNIQUE
#
