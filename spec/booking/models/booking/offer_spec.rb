# frozen_string_literal: true

require "rails_helper"

module Booking
  RSpec.describe Offer, type: :model do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:query) do
      FactoryBot.create(:booking_query,
        organization: organization,
        origin: origin_hub,
        destination: destination_hub)
    end
    let(:shipper) { FactoryBot.create(:organizations_user, organization: organization) }
    let(:origin_hub) { FactoryBot.create(:legacy_hub, organization: organization) }
    let(:destination_hub) { FactoryBot.create(:legacy_hub, organization: organization, name: "Test Hub") }

    it "builds a valid object" do
      expect(FactoryBot.build(:booking_offer, organization: organization,
                                              query: query, shipper: shipper)).to be_valid
    end
  end
end

# == Schema Information
#
# Table name: booking_offers
#
#  id              :uuid             not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#  query_id        :uuid
#  shipper_id      :uuid
#
# Indexes
#
#  index_booking_offers_on_organization_id  (organization_id)
#  index_booking_offers_on_query_id         (query_id)
#  index_booking_offers_on_shipper_id       (shipper_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (query_id => booking_queries.id)
#  fk_rails_...  (shipper_id => users_users.id)
#
