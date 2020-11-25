module Journey
  class LineItemSet < ApplicationRecord
    has_many :line_items
    belongs_to :result
    belongs_to :shipment_request, optional: true
  end
end

# == Schema Information
#
# Table name: journey_line_item_sets
#
#  id                  :uuid             not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  result_id           :uuid
#  shipment_request_id :uuid
#
# Indexes
#
#  index_journey_line_item_sets_on_result_id            (result_id)
#  index_journey_line_item_sets_on_shipment_request_id  (shipment_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (result_id => journey_results.id) ON DELETE => cascade
#  fk_rails_...  (shipment_request_id => journey_shipment_requests.id) ON DELETE => cascade
#
