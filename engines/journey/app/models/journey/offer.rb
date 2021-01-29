module Journey
  class Offer < ApplicationRecord
    has_many :offer_results, inverse_of: :offer
    has_many :results, through: :offer_results
    belongs_to :query, inverse_of: :offers
    has_one_attached :file

    def attachment
      file&.download
    end
  end
end

# == Schema Information
#
# Table name: journey_offers
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  query_id   :uuid
#
# Indexes
#
#  index_journey_offers_on_query_id  (query_id)
#
# Foreign Keys
#
#  fk_rails_...  (query_id => journey_queries.id)
#
