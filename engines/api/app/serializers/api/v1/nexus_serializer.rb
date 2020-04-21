# frozen_string_literal: true

module Api
  module V1
    class NexusSerializer < Api::ApplicationSerializer
      attributes %i[id name latitude longitude modes_of_transport country_name]
    end
  end
end
