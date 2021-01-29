# frozen_string_literal: true

module Api
  module V2
    class OfferDecorator < Draper::Decorator
      decorates "Journey::Offer"

      delegate_all
      delegate :mode_of_transport, :from, :to, to: :route_section

      def url
        Rails.application.routes.url_helpers.rails_blob_url(object.file)
      end
    end
  end
end
