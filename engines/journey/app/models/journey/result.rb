module Journey
  class Result < ApplicationRecord
    belongs_to :result_set
    has_many :offer_results
    has_many :offers, through: :offer_results
    has_many :shipment_requests
    has_many :route_sections
    has_many :line_item_sets

    validates :expiration_date, presence: true
    validates :expiration_date, date: {after: :issued_at}
  end
end

# == Schema Information
#
# Table name: journey_results
#
#  id              :uuid             not null, primary key
#  expiration_date :datetime         not null
#  issued_at       :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  result_set_id   :uuid
#
# Indexes
#
#  index_journey_results_on_result_set_id  (result_set_id)
#
# Foreign Keys
#
#  fk_rails_...  (result_set_id => journey_result_sets.id) ON DELETE => cascade
#
