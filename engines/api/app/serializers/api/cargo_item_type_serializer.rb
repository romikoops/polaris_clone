# frozen_string_literal: true

module Api
  class CargoItemTypeSerializer < Api::ApplicationSerializer
    attribute :description, :dimension_x, :dimension_y
  end
end
