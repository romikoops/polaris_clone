# frozen_string_literal: true

module Api
  module V1
    class StopSerializer < Api::ApplicationSerializer
      set_type "Stop"
      attributes %i[id]
      belongs_to :hub, serializer: HubSerializer
    end
  end
end
