# frozen_string_literal: true

module Api
  module V2
    class OfferSerializer < Api::ApplicationSerializer
      attributes [:id, :url]
    end
  end
end
