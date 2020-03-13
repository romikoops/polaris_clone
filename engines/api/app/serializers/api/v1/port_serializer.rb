# frozen_string_literal: true

module Api
  module V1
    class PortSerializer < Api::ApplicationSerializer
      attributes %i[id name hub_type]
    end
  end
end
