# frozen_string_literal: true

module Api
  module V2
    class OfferSerializer < Api::ApplicationSerializer
      attributes [:id]

      attribute :url do |object|
        Rails.application.routes.url_helpers.rails_blob_url(object.file, disposition: "attachment")
      end
    end
  end
end
