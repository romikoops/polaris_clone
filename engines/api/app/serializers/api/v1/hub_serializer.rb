# frozen_string_literal: true

module Api
  module V1
    class HubSerializer < Api::ApplicationSerializer
      attributes %i[id name]
      belongs_to :nexus, serializer: NexusSerializer
      belongs_to :address, serializer: AddressSerializer
    end
  end
end
