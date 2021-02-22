# frozen_string_literal: true
module Journey
  class ResultSet < ApplicationRecord
    belongs_to :query
    has_many :results
    has_many :result_errors, class_name: "Journey::Error"

    enum status: {
      queued: "queued",
      running: "running",
      completed: "completed",
      failed: "failed"
    }
  end
end

# == Schema Information
#
# Table name: journey_result_sets
#
#  id         :uuid             not null, primary key
#  currency   :string           not null
#  status     :enum
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
