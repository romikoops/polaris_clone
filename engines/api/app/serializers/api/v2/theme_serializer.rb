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
        wide_logo
        landing_page_variant
        landing_page_hero
        landing_page_one
        landing_page_two
        landing_page_three
        color_scheme]

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

      attribute :landing_page_hero do |theme|
        if theme.landing_page_hero.attached?
          Rails.application.routes.url_helpers.rails_blob_url(theme.landing_page_hero)
        else
          ""
        end
      end

      attribute :landing_page_one do |theme|
        if theme.landing_page_one.attached?
          Rails.application.routes.url_helpers.rails_blob_url(theme.landing_page_one)
        else
          ""
        end
      end

      attribute :landing_page_two do |theme|
        if theme.landing_page_two.attached?
          Rails.application.routes.url_helpers.rails_blob_url(theme.landing_page_two)
        else
          ""
        end
      end

      attribute :landing_page_three do |theme|
        if theme.landing_page_three.attached?
          Rails.application.routes.url_helpers.rails_blob_url(theme.landing_page_three)
        else
          ""
        end
      end
    end
  end
end
