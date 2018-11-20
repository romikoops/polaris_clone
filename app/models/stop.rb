# frozen_string_literal: true

class Stop < ApplicationRecord
  belongs_to :itinerary
  belongs_to :hub
  has_many :layovers, dependent: :destroy
  def as_options_json(options = {})
    new_options = options.reverse_merge(
      include: {
        hub: {
          include: {
            nexus:    { only: %i(id name) },
            address: { only: %i(longitude latitude geocoded_address) }
          },
          only:    %i(id name)
        }
      }
    )
    as_json(new_options)
  end
end
