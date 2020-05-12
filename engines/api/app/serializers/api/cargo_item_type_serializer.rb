# frozen_string_literal: true

module Api
  class CargoItemTypeSerializer < Api::ApplicationSerializer
    attribute :description, :width, :length
  end
end
