# frozen_string_literal: true

module Journey
  class Result < ApplicationRecord
    include Sortable

    belongs_to :query
    has_many :shipment_requests
    has_many :route_sections, inverse_of: :result
    has_many :line_item_sets, inverse_of: :result

    validates :expiration_date, presence: true
    validates :expiration_date, date: { after: :issued_at }

    scope :sorted_by_load_type, lambda { |direction|
      joins(query: :cargo_units).order("cargo_class #{direction}")
    }

    scope :sorted_by_last_name, lambda { |direction|
      joins(query: { client: :profile })
        .order("last_name #{direction}")
    }

    scope :sorted_by_origin, lambda { |direction|
      left_joins(route_sections: :from)
        .order("journey_route_points.name #{direction}, journey_route_points.locode #{direction}")
    }

    scope :sorted_by_destination, lambda { |direction|
      left_joins(route_sections: :to)
        .order("journey_route_points.name #{direction}, journey_route_points.locode #{direction}")
    }

    scope :sorted_by_selected_date, lambda { |direction|
      joins(:query).order("cargo_ready_date #{direction}")
    }
  end
end

# == Schema Information
#
# Table name: journey_results
#
#  id                     :uuid             not null, primary key
#  expiration_date        :datetime         not null
#  issued_at              :datetime         not null
#  result_set_id_20210922 :uuid
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  query_id               :uuid
#
# Indexes
#
#  index_journey_results_on_query_id  (query_id)
#
# Foreign Keys
#
#  fk_rails_...  (query_id => journey_queries.id)
#  fk_rails_...  (result_set_id_20210922 => journey_result_sets.id) ON DELETE => cascade
#
