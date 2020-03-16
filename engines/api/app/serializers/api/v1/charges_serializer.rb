# frozen_string_literal: true

module Api
  module V1
    class ChargesSerializer < Api::ApplicationSerializer
      attributes %i[charges route vessel]
      attribute :transit_time, if: proc { |_, params| !quotation_tool?(scope: params.dig(:scope)) }
    end
  end
end
