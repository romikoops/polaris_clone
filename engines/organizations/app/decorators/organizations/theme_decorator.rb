# frozen_string_literal: true

module Organizations
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
        {response_key: :logoWide, value: wide_logo},
        {response_key: :logoSmall, value: small_logo},
        {response_key: :emailLogo, value: email_logo},
        {response_key: :logoLarge, value: large_logo},
        {response_key: :logoWhite, value: white_logo},
        {response_key: :background, value: background},
        {response_key: :bookingProcessImage, value: booking_process_image}
      ].each do |response_key_and_value|
        if response_key_and_value[:value].attached?
          link = Rails.application.routes.url_helpers.rails_blob_url(response_key_and_value[:value])
          response[response_key_and_value[:response_key]] = link
        end
      end

      response.deep_stringify_keys!
    end

    def email_for(branch_raw, mode_of_transport = nil)
      return nil unless branch_raw.is_a?(String) || branch_raw.is_a?(Symbol)

      branch = branch_raw.to_s

      return Settings.emails.booking if emails[branch].blank?

      emails[branch][mode_of_transport] || emails[branch]["general"]
    end
  end
end
