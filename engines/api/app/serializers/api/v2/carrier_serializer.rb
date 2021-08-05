# frozen_string_literal: true

module Api
  module V2
    class CarrierSerializer < Api::ApplicationSerializer
      attributes %i[id code name logo]

      attribute :logo do |carrier|
        Rails.application.routes.url_helpers.rails_blob_url(carrier.logo) if carrier.logo.attached?
      end
    end
  end
end
