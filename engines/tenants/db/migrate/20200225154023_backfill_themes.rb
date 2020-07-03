# frozen_string_literal: true

class BackfillThemes < ActiveRecord::Migration[5.2]
  def up
    attributes = {
      'logoWide' => 'wide_logo',
      'emailLogo' => 'email_logo',
      'logoWhite' => 'white_logo',
      'logoSmall' => 'small_logo',
      'logoLarge' => 'large_logo',
      'background' => 'background',
      'bookingProcessImage' => 'booking_process_image',
      'welcomeEmailImage' => 'welcome_email_image'
    }

    ::Organizations::Organization.find_each do |tenant|
      legacy_theme = tenant.legacy.theme
      next if legacy_theme.empty?

      colors = legacy_theme['colors']
      theme = tenant.theme
      if theme.present?
        theme.update(
          tenant: tenant,
          primary_color: colors['primary'],
          secondary_color: colors['secondary'],
          bright_primary_color: colors['brightPrimary'],
          bright_secondary_color: colors['brightSecondary']
        )
      else
        theme = Tenants::Theme.create!(
          tenant: tenant,
          primary_color: colors['primary'],
          secondary_color: colors['secondary'],
          bright_primary_color: colors['brightPrimary'],
          bright_secondary_color: colors['brightSecondary']
        )
      end

      legacy_theme.except('colors', 'welcome_text').each do |key, url|
        attribute = attributes[key]
        next if url.blank? || attribute.blank?

        file_name = url.split('/').last
        begin
          theme.send(attribute).attach(io: URI.open(url), filename: file_name)
        rescue OpenURI::HTTPError
          next
        end
      end
    end
  end
end
