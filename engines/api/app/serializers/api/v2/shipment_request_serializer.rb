# frozen_string_literal: true

module Api
  module V2
    class ShipmentRequestSerializer < Api::ApplicationSerializer
      attributes %i[preferred_voyage]
    end
  end
end
