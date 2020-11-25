module Journey
  class Shipment < ApplicationRecord
    belongs_to :shipment_request
  end
end

# == Schema Information
#
# Table name: journey_shipments
#
#  id                  :uuid             not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  creator_id          :uuid
#  shipment_request_id :uuid
#
# Indexes
#
#  index_journey_shipments_on_creator_id           (creator_id)
#  index_journey_shipments_on_shipment_request_id  (shipment_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users_users.id) ON DELETE => cascade
#  fk_rails_...  (shipment_request_id => journey_shipment_requests.id) ON DELETE => cascade
#
