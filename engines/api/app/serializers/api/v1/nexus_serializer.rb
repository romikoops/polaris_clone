# frozen_string_literal: true

module Api
  module V1
    class NexusSerializer < ActiveModel::Serializer
      attributes %i[id name]
    end
  end
end
