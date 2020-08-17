# frozen_string_literal: true

module Booking
  class Offer < ApplicationRecord
    belongs_to :organization, class_name: "Organizations::Organization"
    belongs_to :query, class_name: "Booking::Query"
    belongs_to :shipper, class_name: "Organizations::User"

    delegate :creator, :company, :category, :desired_start_date, :origin, :destination, to: :query
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
