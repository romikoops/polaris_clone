# frozen_string_literal: true

module Journey
  class OfferLineItemSet < ApplicationRecord
    belongs_to :offer
    belongs_to :line_item_set
  end
end

# == Schema Information
#
# Table name: journey_offer_line_item_sets
#
#  id               :uuid             not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  line_item_set_id :uuid
#  offer_id         :uuid
#
# Indexes
#
#  index_journey_offer_line_item_sets_on_line_item_set_id  (line_item_set_id)
#  index_journey_offer_line_item_sets_on_offer_id          (offer_id)
#
# Foreign Keys
#
#  fk_rails_...  (line_item_set_id => journey_line_item_sets.id) ON DELETE => cascade
#  fk_rails_...  (offer_id => journey_offers.id) ON DELETE => cascade
#
