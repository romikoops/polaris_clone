# frozen_string_literal: true

module Api
  module V2
    class ResultDecorator < ResultFormatter::ResultDecorator
      delegate_all

      delegate :organization, :cargo_units, :user, :client, :cargo_ready_date, :cargo_delivery_date, to: :query
      decorates_association :client, with: Api::V1::UserDecorator
      decorates_association :query, with: QueryDecorator

      def carrier
        @carrier ||= main_freight_section.carrier
      end

      def carrier_logo
        @carrier_logo ||= logo.attached? ? Rails.application.routes.url_helpers.rails_blob_url(logo) : nil
      end
    end
  end
end
