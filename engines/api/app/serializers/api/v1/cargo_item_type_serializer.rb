# frozen_string_literal: true

module Api
  module V1
    class CargoItemTypeSerializer < Api::ApplicationSerializer
      attributes %i[width length description]
    end
  end
end
