# frozen_string_literal: true
module Journey
  class OfferResult < ApplicationRecord
    belongs_to :offer
    belongs_to :result
  end
end

# == Schema Information
#
# Table name: journey_offer_results
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  offer_id   :uuid
#  result_id  :uuid
#
# Indexes
#
#  index_journey_offer_results_on_offer_id   (offer_id)
#  index_journey_offer_results_on_result_id  (result_id)
#
# Foreign Keys
#
#  fk_rails_...  (offer_id => journey_offers.id) ON DELETE => cascade
#  fk_rails_...  (result_id => journey_results.id) ON DELETE => cascade
#
