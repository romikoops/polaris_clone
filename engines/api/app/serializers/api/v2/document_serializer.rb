# frozen_string_literal: true

module Api
  module V2
    class DocumentSerializer < Api::ApplicationSerializer
      attributes %i[type]

      attribute :url do |object|
        Rails.application.routes.url_helpers.rails_blob_url(object.file)
      end
    end
  end
end
