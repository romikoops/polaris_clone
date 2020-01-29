# frozen_string_literal: true

module Legacy
  class ItinerarySerializer < ActiveModel::Serializer
    attributes %i[id mode_of_transport name stops]

    def stops
      object.stops.as_json(
        include: {
          hub: {
            include: {
              nexus: { only: %i[id name] },
              address: { only: %i[longitude latitude geocoded_address] }
            },
            only: %i[id name]
          }
        },
        only: %i[id index]
      )
    end
  end
end

# == Schema Information
#
# Table name: itineraries
#
#  id                :bigint           not null, primary key
#  mode_of_transport :string
#  name              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sandbox_id        :uuid
#  tenant_id         :integer
#
# Indexes
#
#  index_itineraries_on_mode_of_transport  (mode_of_transport)
#  index_itineraries_on_name               (name)
#  index_itineraries_on_sandbox_id         (sandbox_id)
#  index_itineraries_on_tenant_id          (tenant_id)
#
