# frozen_string_literal: true

module Schedules
  class Schedule < ApplicationRecord
    belongs_to :organization, class_name: "Organizations::Organization"
    validates :vessel_name, presence: true
    validates :origin, presence: true
    validates :destination, presence: true
    validates :destination_arrival, presence: true

    enum mode_of_transport: {
      ocean: "ocean",
      air: "air",
      rail: "rail",
      truck: "truck"
    }
  end
end

# == Schema Information
#
# Table name: schedules_schedules
#
#  id                  :uuid             not null, primary key
#  carrier             :string           default("")
#  closing_date        :datetime         not null
#  destination         :string           not null
#  destination_arrival :datetime         not null
#  mode_of_transport   :enum             not null
#  origin              :string           not null
#  origin_departure    :datetime         not null
#  service             :string           default("")
#  vessel_code         :string           default("")
#  vessel_name         :string           default("")
#  voyage_code         :string           default("")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  organization_id     :uuid
#
# Indexes
#
#  index_schedules_schedules_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id) ON DELETE => cascade
#
