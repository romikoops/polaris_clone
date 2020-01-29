# frozen_string_literal: true

module Legacy
  class Stop < ApplicationRecord
    self.table_name = 'stops'
    belongs_to :itinerary
    belongs_to :hub
    has_many :layovers, dependent: :destroy
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

  end
end

# == Schema Information
#
# Table name: stops
#
#  id           :bigint           not null, primary key
#  index        :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  hub_id       :integer
#  itinerary_id :integer
#  sandbox_id   :uuid
#
# Indexes
#
#  index_stops_on_sandbox_id  (sandbox_id)
#
