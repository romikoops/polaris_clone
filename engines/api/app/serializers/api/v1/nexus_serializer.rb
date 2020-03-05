# frozen_string_literal: true

module Api
  module V1
    class NexusSerializer < ActiveModel::Serializer
      attributes %i[id name latitude longitude modes_of_transport]
    end
  end
end
