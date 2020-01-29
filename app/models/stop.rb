# frozen_string_literal: true

class Stop < Legacy::Stop
  belongs_to :itinerary
  belongs_to :hub
  has_many :layovers, dependent: :destroy
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

  validates_uniqueness_of :index, scope: %i(itinerary_id hub_id)

  def as_options_json(options = {})
    new_options = options.reverse_merge(
      include: {
        hub: {
          methods: %i(available_trucking),
          include: {
            nexus: { only: %i(id name) },
            address: { only: %i(longitude latitude geocoded_address) }
          },
          only: %i(id name)
        }
      }
    )
    as_json(new_options)
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
