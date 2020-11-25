module Journey
  class ResultSet < ApplicationRecord
    belongs_to :query
    has_many :results
  end
end

# == Schema Information
#
# Table name: journey_result_sets
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  query_id   :uuid
#
# Indexes
#
#  index_journey_result_sets_on_query_id  (query_id)
#
# Foreign Keys
#
#  fk_rails_...  (query_id => journey_queries.id) ON DELETE => cascade
#
