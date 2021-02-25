# frozen_string_literal: true

module Api
  module V2
    class ThemeSerializer < Api::ApplicationSerializer
      attributes %i[id
        organization_id
        emails
        websites
        addresses
        email_links
        name
        phones
        background
        small_logo
        large_logo
        white_logo
        wide_logo]

      attribute :background do |theme|
        if theme.background.attached?
          Rails.application.routes.url_helpers.rails_blob_url(theme.background)
        else
          ""
        end
      end

      attribute :small_logo do |theme|
        if theme.small_logo.attached?
          Rails.application.routes.url_helpers.rails_blob_url(theme.small_logo)
        else
          ""
        end
      end

      attribute :large_logo do |theme|
        if theme.large_logo.attached?
          Rails.application.routes.url_helpers.rails_blob_url(theme.large_logo)
        else
          ""
        end
      end

      attribute :white_logo do |theme|
        if theme.white_logo.attached?
          Rails.application.routes.url_helpers.rails_blob_url(theme.white_logo)
        else
          ""
        end
      end

      attribute :wide_logo do |theme|
        if theme.wide_logo.attached?
          Rails.application.routes.url_helpers.rails_blob_url(theme.wide_logo)
        else
          ""
        end
      end
    end
  end
end
