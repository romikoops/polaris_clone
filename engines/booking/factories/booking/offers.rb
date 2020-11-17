# frozen_string_literal: true

FactoryBot.define do
  factory :booking_offer, class: "Booking::Offer" do
    association :organization, factory: :organizations_organization
    association :shipper, factory: :organizations_user
    association :query, factory: :booking_query
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
