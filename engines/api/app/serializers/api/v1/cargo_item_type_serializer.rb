# frozen_string_literal: true

module Api
  module V1
    class CargoItemTypeSerializer < Api::ApplicationSerializer
      attributes %i[dimension_x dimension_y description]
    end
  end
end
