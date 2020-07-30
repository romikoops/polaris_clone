# frozen_string_literal: true

module Api
  module V1
    class XlsxSerializer < Api::ApplicationSerializer
      attribute :url do |object|
        Rails.application.routes.url_helpers.rails_blob_url(object.file, disposition: "attachment")
      end
    end
  end
end
