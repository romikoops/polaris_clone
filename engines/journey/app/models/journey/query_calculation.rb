# frozen_string_literal: true

module Journey
  class QueryCalculation < ApplicationRecord
    belongs_to :query
    has_many :journey_errors, class_name: "Journey::Error"
    enum status: {
      queued: "queued",
      running: "running",
      completed: "completed",
      failed: "failed"
    }
    validates :status, presence: true
  end
end

# == Schema Information
#
# Table name: journey_query_calculations
#
#  id           :uuid             not null, primary key
#  on_carriage  :boolean          not null
#  pre_carriage :boolean          not null
#  status       :enum
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  query_id     :uuid
#
# Indexes
#
#  index_journey_query_calculations_on_query_id  (query_id)
#  index_journey_query_calculations_on_status    (status)
#
# Foreign Keys
#
#  fk_rails_...  (query_id => journey_queries.id) ON DELETE => cascade
#
