# frozen_string_literal: true

module Journey
  class LineItemSet < ApplicationRecord
    has_many :line_items, inverse_of: :line_item_set
    belongs_to :result, inverse_of: :line_item_sets
    belongs_to :shipment_request, optional: true
    has_many :offer_line_item_sets
    has_many :offers, through: :offer_line_item_sets
    validates :reference, uniqueness: true

    before_validation :set_reference

    private

    def set_reference
      self.reference = Journey::ImcReference.new(date: Time.zone.now).reference if reference.blank?
    end
  end
end

# == Schema Information
#
# Table name: journey_line_item_sets
#
#  id                  :uuid             not null, primary key
#  reference           :string
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
