# frozen_string_literal: true

module Api
  module V2
    class InteractionsController < ApiController
      def index
        render json: { data: Tracker::Interaction.pluck(:name) }
      end
    end
  end
end
