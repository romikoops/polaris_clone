# frozen_string_literal: true
module Journey
  class RouteSection < ApplicationRecord
    belongs_to :from, class_name: "Journey::RoutePoint"
    belongs_to :to, class_name: "Journey::RoutePoint"
    belongs_to :result, class_name: "Journey::Result", inverse_of: :route_sections
    has_many :line_items
    enum mode_of_transport: {
      ocean: "ocean",
      air: "air",
      rail: "rail",
      truck: "truck",
      carriage: "carriage"
    }

    validates :service, presence: true
    validates :carrier, presence: true
    validates :order, presence: true
    validates :mode_of_transport, presence: true
  end
end

# == Schema Information
#
# Table name: journey_route_sections
#
#  id                :uuid             not null, primary key
#  carrier           :string           not null
#  mode_of_transport :enum
#  order             :integer          not null
#  service           :string           not null
#  transit_time      :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  from_id           :uuid
#  result_id         :uuid
#  to_id             :uuid
#
# Indexes
#
#  index_journey_route_sections_on_from_id            (from_id)
#  index_journey_route_sections_on_mode_of_transport  (mode_of_transport)
#  index_journey_route_sections_on_result_id          (result_id)
#  index_journey_route_sections_on_to_id              (to_id)
#
# Foreign Keys
#
#  fk_rails_...  (from_id => journey_route_points.id) ON DELETE => cascade
#  fk_rails_...  (result_id => journey_results.id) ON DELETE => cascade
#  fk_rails_...  (to_id => journey_route_points.id) ON DELETE => cascade
#
