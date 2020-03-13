# frozen_string_literal: true

module Api
  module V1
    class ChargesSerializer < Api::ApplicationSerializer
      attributes %i[charges route vessel]
      attribute :transit_time, unless: :quotation_tool?
      delegate :vessel, :charges, :route, :transit_time, to: :object
    end
  end
end
