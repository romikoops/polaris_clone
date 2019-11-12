# frozen_string_literal: true

module Tenants
  class ThemeDecorator < SimpleDelegator
    def legacy_format
      response = {
        colors: {
          primary: primary_color,
          secondary: secondary_color,
          brightPrimary: bright_primary_color,
          brightSecondary: bright_secondary_color
        }
      }
      [
        { response_key: :logoWide, value: wide_logo },
        { response_key: :logoSmall, value: small_logo },
        { response_key: :emailLogo, value: email_logo },
        { response_key: :logoLarge, value: large_logo },
        { response_key: :logoWhite, value: white_logo },
        { response_key: :background, value: background },
        { response_key: :booking_process_image, value: booking_process_image }
      ].each do |response_key_and_value|
        if response_key_and_value[:value].attached?
          response[response_key_and_value[:response_key]] = Rails.application.routes.url_helpers.rails_blob_url(response_key_and_value[:value])
        end
      end

      response.deep_stringify_keys!
    end
  end
end
