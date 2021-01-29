module Journey
  class Result < ApplicationRecord
    include Sortable

    belongs_to :result_set
    has_many :offer_results
    has_many :offers, through: :offer_results
    has_many :shipment_requests
    has_many :route_sections, inverse_of: :result
    has_many :line_item_sets, inverse_of: :result
    has_one :query, through: :result_set

    validates :expiration_date, presence: true
    validates :expiration_date, date: {after: :issued_at}

    scope :sorted_by_load_type, ->(direction) {
      joins(result_set: {query: :cargo_units}).order("cargo_class #{direction}")
    }

    scope :sorted_by_last_name, ->(direction) {
      joins(result_set: {query: {client: :profile}})
        .order("last_name #{direction}")
    }

    scope :sorted_by_origin, ->(direction) {
      left_joins(route_sections: :from)
        .order("journey_route_points.name #{direction}, journey_route_points.locode #{direction}")
    }

    scope :sorted_by_destination, ->(direction) {
      left_joins(route_sections: :to)
        .order("journey_route_points.name #{direction}, journey_route_points.locode #{direction}")
    }

    scope :sorted_by_selected_date, ->(direction) {
      joins(result_set: :query).order("cargo_ready_date #{direction}")
    }
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
