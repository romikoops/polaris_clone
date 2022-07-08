# frozen_string_literal: true

module Api
  module V2
    class InteractionsController < ApiController
      def index
        render json: { data: Tracker::Interaction.all }
      end
    end
  end
end
