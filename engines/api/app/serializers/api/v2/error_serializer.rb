# frozen_string_literal: true

module Api
  module V2
    class ErrorSerializer < Api::ApplicationSerializer
      attributes %i[id carrier code limit mode_of_transport property service value cargo_unit_id]
    end
  end
end
