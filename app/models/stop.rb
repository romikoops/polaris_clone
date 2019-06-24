# frozen_string_literal: true

class Stop < Legacy::Stop
  belongs_to :itinerary
  belongs_to :hub
  has_many :layovers, dependent: :destroy

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
#  id           :bigint(8)        not null, primary key
#  hub_id       :integer
#  itinerary_id :integer
#  index        :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
